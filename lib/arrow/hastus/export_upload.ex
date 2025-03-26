defmodule Arrow.Hastus.ExportUpload do
  @moduledoc """
  Functions for validating and parsing HASTUS exports
  """

  import Ecto.Query, only: [from: 2]

  require Logger

  @type error_message :: String.t()
  @type error_details :: list(String.t())
  @type rescued_exception_error :: {:ok, {:error, list({error_message(), []})}}

  @filenames [
    ~c"all_calendar.txt",
    ~c"all_calendar_dates.txt",
    ~c"all_agency.txt",
    ~c"all_routes.txt",
    ~c"all_shapes.txt",
    ~c"all_stop_times.txt",
    ~c"all_stops.txt",
    ~c"all_trips.txt"
  ]

  @doc """
  Parses a HASTUS export and returns a list of data
  Includes a rescue clause to catch errors while parsing user-provided data
  """
  @spec extract_data_from_upload(%{:path => binary()}, String.t()) ::
          {:ok, {:error, error_message} | {:ok, list(map()), String.t(), binary()}}
          | rescued_exception_error()
  def extract_data_from_upload(%{path: zip_path}, user_id) do
    tmp_dir = ~c"tmp/hastus/#{user_id}"

    with {:ok, zip_file_data} <- File.read(zip_path),
         {:ok, unzipped_file_list} <-
           :zip.unzip(zip_file_data, [{:file_list, @filenames}, {:cwd, tmp_dir}]),
         {:ok, file_map} <- read_csvs(unzipped_file_list, tmp_dir),
         revenue_trips <- Stream.filter(file_map["all_trips.txt"], &revenue_trip?/1),
         :ok <- validate_trip_shapes(revenue_trips),
         {:ok, line} <- infer_line(revenue_trips, file_map["all_stop_times.txt"]),
         {:ok, _branches} <-
           infer_green_line_branches(line, revenue_trips, file_map["all_stop_times.txt"]) do
      {:ok, {:ok, parse_export(file_map, tmp_dir), line, zip_file_data}}
    else
      {:error, error} ->
        _ = File.rm_rf!(tmp_dir)
        {:ok, {:error, error}}
    end
  rescue
    e ->
      Logger.warning(
        "Hastus.ExportUpload failed to parse zip, message=#{Exception.format(:error, e, __STACKTRACE__)}"
      )

      # Must be wrapped in an ok tuple for caller, consume_uploaded_entry/3
      {:ok, {:error, "Could not parse zip."}}
  end

  @spec upload_to_s3(binary(), String.t()) ::
          {:ok, :disabled} | {:ok, String.t()} | {:error, term()}
  def upload_to_s3(file_data, filename) do
    if Application.fetch_env!(:arrow, :hastus_export_storage_enabled?) do
      do_upload(file_data, filename)
    else
      {:ok, "disabled"}
    end
  end

  defp do_upload(file_data, filename) do
    s3_bucket = Application.fetch_env!(:arrow, :hastus_export_storage_bucket)
    path = get_upload_path(filename)

    upload_op = ExAws.S3.put_object(s3_bucket, path, file_data, content_type: "application/zip")

    {mod, fun} = Application.fetch_env!(:arrow, :hastus_export_storage_request_fn)

    case apply(mod, fun, [upload_op]) do
      {:ok, _} -> {:ok, Path.join(["s3://", s3_bucket, path])}
      {:error, _} = error -> error
    end
  end

  defp get_upload_path(filename) do
    prefix_env = Application.get_env(:arrow, :hastus_export_storage_prefix_env)
    s3_prefix = Application.fetch_env!(:arrow, :hastus_export_storage_prefix)

    usename_prefix =
      if Application.fetch_env!(:arrow, :use_username_prefix?) do
        {username, _} = System.cmd("whoami", [])
        String.trim(username)
      end

    [prefix_env, usename_prefix, s3_prefix, filename]
    |> Enum.reject(&is_nil/1)
    |> Path.join()
  end

  defp read_csvs(unzip, tmp_dir) do
    missing_files = Enum.filter(@filenames, &(get_unzipped_file_path(&1, tmp_dir) not in unzip))

    if Enum.any?(missing_files) do
      {:error,
       ["The following files are missing from the export: #{Enum.join(missing_files, ", ")}"]}
    else
      map =
        @filenames
        |> Enum.map(fn filename ->
          data =
            filename
            |> get_unzipped_file_path(tmp_dir)
            |> File.stream!()
            |> CSV.decode!(headers: true)

          {to_string(filename), data}
        end)
        |> Map.new()

      {:ok, map}
    end
  end

  defp validate_trip_shapes(revenue_trips) do
    trips_with_invalid_shapes =
      revenue_trips
      |> Stream.filter(&(&1["shape_id"] in [nil, ""]))
      |> Stream.map(& &1["trip_id"])

    if Enum.any?(trips_with_invalid_shapes),
      do: {:error, "Trips found with invalid shapes"},
      else: :ok
  end

  defp infer_line(revenue_trips, exported_stop_times) do
    revenue_trip_ids = Enum.map(revenue_trips, & &1["trip_id"])

    exported_stop_ids =
      exported_stop_times
      |> Enum.filter(&(&1["trip_id"] in revenue_trip_ids))
      |> Enum.map(& &1["stop_id"])
      |> Enum.uniq()

    lines =
      Arrow.Repo.all(
        from st in Arrow.Gtfs.StopTime,
          where: st.stop_id in ^exported_stop_ids,
          join: t in Arrow.Gtfs.Trip,
          on: t.id == st.trip_id,
          join: r in Arrow.Gtfs.Route,
          on: r.id == t.route_id,
          select: r.line_id,
          distinct: r.line_id
      )

    case lines do
      [line] -> {:ok, line}
      [] -> {:error, "Export does not contain any valid routes"}
      _ -> {:error, "Export contains more than one route"}
    end
  end

  @spec infer_green_line_branches(String.t(), Enumerable.t(), Enumerable.t()) ::
          {:ok, [String.t()]} | {:error, String.t()}
  defp infer_green_line_branches("line-Green", revenue_trips, all_stop_times) do
    {branches, unknown_trips} =
      Enum.reduce(revenue_trips, {MapSet.new([]), []}, fn revenue_trip,
                                                          {branches, unknown_trips} ->
        if revenue_trip["via_variant"] in ["B", "C", "D", "E"] do
          {MapSet.put(branches, "Green-" <> revenue_trip["via_variant"]), unknown_trips}
        else
          {branches, [revenue_trip | unknown_trips]}
        end
      end)

    stop_times_by_trip_id = Enum.group_by(all_stop_times, & &1["trip_id"])

    canonical_stops_by_branch =
      Enum.group_by(
        Arrow.Repo.all(
          from t in Arrow.Gtfs.Trip,
            where:
              t.route_id in ["Green-B", "Green-C", "Green-D", "Green-E"] and
                t.service_id == "canonical",
            join: st in Arrow.Gtfs.StopTime,
            on: t.id == st.trip_id,
            select: %{route_id: t.route_id, stop_id: st.stop_id}
        ),
        & &1.route_id
      )

    {branches, unknown_trips} =
      unknown_trips
      |> Enum.group_by(& &1["via_variant"])
      |> Map.values()
      |> Enum.reduce({branches, []}, fn [revenue_trip | _], {branches, unknown_trips} ->
        stop_ids_for_trip =
          Enum.map(stop_times_by_trip_id[revenue_trip["trip_id"]], & &1["stop_id"])

        case find_branch_based_on_stop_times(canonical_stops_by_branch, stop_ids_for_trip) do
          nil -> {branches, [revenue_trip | unknown_trips]}
          route_id -> {MapSet.put(branches, route_id), unknown_trips}
        end
      end)

    case unknown_trips do
      [example_trip | _] ->
        {:error,
         "Unable to infer the Green Line branch for #{example_trip["route_id"]}, #{example_trip["trp_direction"]}, #{example_trip["via_variant"]}, #{example_trip["route"]}. Please request the via_variant be updated to the branch name and provide an updated export"}

      [] ->
        {:ok, branches}
    end
  end

  defp infer_green_line_branches(_line, _revenue_trips, _all_stop_times), do: {:ok, []}

  defp find_branch_based_on_stop_times(canonical_stops_by_branch, stop_ids_for_trip) do
    case Enum.filter(canonical_stops_by_branch, fn {_route_id, canonical_stops} ->
           Enum.all?(
             stop_ids_for_trip,
             &(&1 in Enum.map(canonical_stops, fn canonical_stop -> canonical_stop.stop_id end))
           )
         end) do
      [] -> nil
      [{route_id, _canonical_stops}] -> route_id
      [_ | _] -> nil
    end
  end

  defp get_unzipped_file_path(filename, tmp_dir), do: ~c"#{tmp_dir}/#{filename}"

  defp parse_export(
         %{"all_calendar.txt" => calendar, "all_calendar_dates.txt" => calendar_dates},
         tmp_dir
       ) do
    imported_service =
      calendar
      |> Stream.concat(calendar_dates)
      |> Enum.reduce([], fn
        # calendar rows
        %{
          "service_id" => service_id,
          "start_date" => start_date_string,
          "end_date" => end_date_string
        },
        acc ->
          [start_year, start_month, start_day] = extract_date_parts(start_date_string)
          [end_year, end_month, end_day] = extract_date_parts(end_date_string)

          date = %{
            start_date: Date.from_iso8601!("#{start_year}-#{start_month}-#{start_day}"),
            end_date: Date.from_iso8601!("#{end_year}-#{end_month}-#{end_day}")
          }

          add_or_update_list(acc, service_id, date)

        # calendar_dates rows
        %{"service_id" => service_id, "date" => date_string, "exception_type" => "1"}, acc ->
          [year, month, day] = extract_date_parts(date_string)

          date = %{
            start_date: Date.from_iso8601!("#{year}-#{month}-#{day}"),
            end_date: Date.from_iso8601!("#{year}-#{month}-#{day}")
          }

          add_or_update_list(acc, service_id, date)

        _, acc ->
          acc
      end)

    _ = File.rm_rf!(tmp_dir)

    imported_service
  end

  defp extract_date_parts(date_string),
    do: Regex.run(~r/^(\d{4})(\d{2})(\d{2})/, date_string, capture: :all_but_first)

  defp add_or_update_list([], new_service_id, new_date),
    do: [%{name: new_service_id, service_dates: [new_date], import?: true}]

  defp add_or_update_list(
         [h = %{name: service_id, service_dates: existing_dates} | t],
         service_id,
         new_date
       ) do
    [%{h | service_dates: Enum.uniq(existing_dates ++ [new_date]), import?: true} | t]
  end

  defp add_or_update_list([h | t], new_service_id, new_date),
    do: [h | add_or_update_list(t, new_service_id, new_date)]

  defp revenue_trip?(%{"route_id" => route_id, "trp_is_in_service" => "X"}),
    do: Regex.match?(~r/^\d+_*-.+$/, route_id)

  defp revenue_trip?(_), do: false
end
