defmodule Arrow.Hastus.ExportUpload do
  @moduledoc """
  Functions for validating and parsing HASTUS exports
  """

  import Ecto.Query, only: [from: 2]

  require Logger

  alias Arrow.Hastus.TripRouteDirection

  @type t :: %__MODULE__{
          services: list(map()),
          line_id: String.t(),
          trip_route_directions: list(TripRouteDirection.t()),
          zip_binary: binary(),
          dup_service_ids_amended?: boolean()
        }

  @enforce_keys [
    :services,
    :line_id,
    :trip_route_directions,
    :zip_binary,
    :dup_service_ids_amended?
  ]
  defstruct @enforce_keys

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
          {:ok, {:ok, t()} | {:error, String.t()}}
  def extract_data_from_upload(%{path: zip_path}, user_id) do
    tmp_dir = ~c"tmp/hastus/#{user_id}"

    with {:ok, zip_bin, file_map} <- read_zip(zip_path, tmp_dir),
         {:ok, zip_bin, file_map, amended?} <- amend_service_ids(zip_bin, file_map, tmp_dir),
         revenue_trips <- Stream.filter(file_map["all_trips.txt"], &revenue_trip?/1),
         :ok <- validate_trip_shapes(revenue_trips),
         {:ok, line_id} <- infer_line(revenue_trips, file_map["all_stop_times.txt"]),
         {:ok, trip_route_directions} <-
           infer_green_line_branches(line_id, revenue_trips, file_map["all_stop_times.txt"]) do
      services = parse_export(file_map, tmp_dir)

      export_data = %__MODULE__{
        services: services,
        line_id: line_id,
        trip_route_directions: trip_route_directions,
        zip_binary: zip_bin,
        dup_service_ids_amended?: amended?
      }

      {:ok, {:ok, export_data}}
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

  @spec read_zip(Path.t(), Path.t()) :: {:ok, binary(), map()} | {:error, term()}
  defp read_zip(zip_path, tmp_dir) do
    with {:ok, zip_bin} <- File.read(zip_path),
         {:ok, unzipped_file_list} <- :zip.unzip(zip_bin, file_list: @filenames, cwd: tmp_dir),
         {:ok, file_map} <- read_csvs(unzipped_file_list, tmp_dir) do
      {:ok, zip_bin, file_map}
    end
  end

  # Detects service IDs in the export that are duplicates of existing
  # service IDs in hastus_services.
  # If any such service IDs exist, edits the export so that they are
  # unique.
  #
  # Returns:
  # - the (potentially edited) binary of the export ZIP,
  # - the (potentially edited) map of %{filename => parsed_csv_rows}, and
  # - a boolean indicating whether edits occurred.
  @spec amend_service_ids(binary(), map(), charlist()) ::
          {:ok, binary(), map(), amended? :: boolean()} | {:error, term()}
  defp amend_service_ids(zip_bin, file_map, tmp_dir) do
    export_service_ids =
      MapSet.new(for row <- file_map["all_calendar.txt"], do: row["service_id"])

    existing_service_ids =
      MapSet.new(Arrow.Repo.all(from s in Arrow.Hastus.Service, select: s.name))

    dups = MapSet.intersection(export_service_ids, existing_service_ids)

    if Enum.empty?(dups) do
      {:ok, zip_bin, file_map, false}
    else
      other_service_ids =
        MapSet.difference(
          MapSet.union(export_service_ids, existing_service_ids),
          dups
        )

      {replacements, _ids} =
        Enum.map_reduce(dups, other_service_ids, fn dup, other_ids ->
          new_id = get_amended_service_id(dup, other_ids)
          other_ids = MapSet.put(other_ids, new_id)
          {{dup, new_id}, other_ids}
        end)

      Enum.each(replacements, &amend_service_id(&1, tmp_dir))

      with {:ok, zip_path} <- write_amended_zip(tmp_dir),
           {:ok, amended_zip_bin, amended_file_map} <- read_zip(zip_path, tmp_dir) do
        {:ok, amended_zip_bin, amended_file_map, true}
      end
    end
  end

  defp get_amended_service_id(dup, other_ids, deduplicator \\ 1) do
    new_id = "#{dup}-#{deduplicator}"

    if new_id in other_ids,
      do: get_amended_service_id(dup, other_ids, deduplicator + 1),
      else: new_id
  end

  defp tables_with_service_or_trip_id do
    ["all_calendar.txt", "all_calendar_dates.txt", "all_trips.txt", "all_stop_times.txt"]
  end

  defp amend_service_id({old_id, new_id}, tmp_dir) do
    # `CSV.encode/2` mangles (read: standardizes, which may or may not cause issues for gtfs_creator et al)
    # values in other columns if we use it to rewrite the CSVs.
    # Instead, let's do a very careful find-and-replace.
    pattern = ~r"""
    (*ANYCRLF)               # Sets newline convention to accept LF, CRLF, or CR
    (\G|,)                   # left-delimited by start of the search, or a comma
    (\d+-)?                  # a trip ID is formed by prefixing service ID with a number--this captures the prefix
    #{Regex.escape(old_id)}  # the service ID to replace
    ($|,)                    # right-delimited by end of line or a comma
    """x

    replacement = "\\1\\2#{new_id}\\3"

    for filename <- tables_with_service_or_trip_id() do
      path = Path.join(tmp_dir, filename)
      tmp_path = path <> ".tmp"

      :ok =
        path
        |> File.stream!()
        |> Stream.map(fn line -> Regex.replace(pattern, line, replacement) end)
        |> Stream.into(File.stream!(tmp_path))
        |> Stream.run()

      File.rename!(tmp_path, path)
    end
  end

  # Writes a new ZIP containing the amended CSVs and returns its path.
  @spec write_amended_zip(charlist()) :: {:ok, charlist()} | {:error, term()}
  defp write_amended_zip(tmp_dir) do
    # :cwd opt does not apply to the path being written to, so we need to do it ourselves.
    zip_path = Path.join(tmp_dir, "amended_export.zip")
    :zip.zip(to_charlist(zip_path), @filenames, cwd: tmp_dir)
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
       "The following files are missing from the export: #{Enum.join(missing_files, ", ")}"}
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
          {:ok, [TripRouteDirection.t()]} | {:error, String.t()}
  defp infer_green_line_branches("line-Green", revenue_trips, all_stop_times) do
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

    result =
      revenue_trips
      |> Enum.group_by(&{&1["route_id"], &1["via_variant"], &1["avi_code"]})
      |> Map.values()
      |> Enum.map(&List.first/1)
      |> Enum.map(
        &infer_green_line_branch_for_trip(&1, canonical_stops_by_branch, stop_times_by_trip_id)
      )
      |> Enum.group_by(&elem(&1, 0))

    case result do
      %{error: unknown_trips} ->
        message =
          unknown_trips
          |> Enum.map(&elem(&1, 1))
          |> Enum.map_join("\n", fn trip ->
            "Unable to infer the Green Line branch for #{trip["route_id"]}, #{trip["trp_direction"]}, #{trip["via_variant"]}, #{trip["route"]}. Please request the via_variant be updated to the branch name and provide an updated export"
          end)

        {:error, message}

      %{ok: trip_route_directions} ->
        {:ok, trip_route_directions |> Enum.map(&elem(&1, 1))}
    end
  end

  defp infer_green_line_branches(_line, _revenue_trips, _all_stop_times), do: {:ok, []}

  defp infer_green_line_branch_for_trip(trip, canonical_stops_by_branch, stop_times_by_trip_id) do
    if trip["via_variant"] in ["B", "C", "D", "E"] do
      {:ok,
       %{
         hastus_route_id: trip["route_id"],
         via_variant: trip["via_variant"],
         avi_code: trip["avi_code"],
         route_id: "Green-#{trip["via_variant"]}"
       }}
    else
      stop_ids_for_trip = Enum.map(stop_times_by_trip_id[trip["trip_id"]], & &1["stop_id"])

      case find_branch_based_on_stop_times(canonical_stops_by_branch, stop_ids_for_trip) do
        nil ->
          {:error, trip}

        route_id ->
          {:ok,
           %{
             hastus_route_id: trip["route_id"],
             via_variant: trip["via_variant"],
             avi_code: trip["avi_code"],
             route_id: route_id
           }}
      end
    end
  end

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
         %{
           "all_calendar.txt" => calendar,
           "all_calendar_dates.txt" => calendar_dates,
           "all_trips.txt" => trips
         },
         tmp_dir
       ) do
    service_ids =
      trips
      |> Stream.map(& &1["service_id"])
      |> Stream.reject(&is_nil/1)
      |> Enum.uniq()
      |> Enum.sort()

    imported_service =
      service_ids
      |> Enum.map(fn service_id ->
        case Enum.find(calendar, &(&1["service_id"] == service_id)) do
          %{
            "service_id" => service_id,
            "start_date" => start_date_string,
            "end_date" => end_date_string
          } = service ->
            [start_year, start_month, start_day] = extract_date_parts(start_date_string)
            [end_year, end_month, end_day] = extract_date_parts(end_date_string)
            start_date = Date.from_iso8601!("#{start_year}-#{start_month}-#{start_day}")
            end_date = Date.from_iso8601!("#{end_year}-#{end_month}-#{end_day}")
            range = Date.range(start_date, end_date)

            exceptions =
              calendar_dates
              |> Enum.filter(&(&1["service_id"] == service_id and &1["exception_type"] == "2"))
              |> Enum.map(&date_field_to_date/1)

            additions =
              calendar_dates
              |> Enum.filter(&(&1["service_id"] == service_id and &1["exception_type"] == "1"))
              |> Enum.map(&date_field_to_date/1)

            dates =
              range
              |> Enum.chunk_while(
                {nil, nil},
                &chunk_dates(&1, &2, service, exceptions),
                &chunk_dates/1
              )
              |> apply_additions(additions)
              |> merge_adjacent_service_dates([])

            %{name: service_id, service_dates: dates}

          _ ->
            %{name: service_id, service_dates: []}
        end
      end)

    _ = File.rm_rf!(tmp_dir)

    imported_service
  end

  defp chunk_dates(date, {start_date, last_date}, service, exceptions) do
    day_name = date |> Calendar.strftime("%A") |> String.downcase()

    cond do
      # date is active
      service[day_name] == "1" and date not in exceptions ->
        if is_nil(start_date) do
          # first date of a new timeframe
          {:cont, {date, date}}
        else
          # extend the current timeframe
          {:cont, {start_date, date}}
        end

      # date is inactive and we're still looking for next timeframe
      is_nil(last_date) ->
        {:cont, {nil, nil}}

      # date is inactive and we have a timeframe to return
      true ->
        {:cont, %{start_date: start_date, end_date: last_date}, {nil, nil}}
    end
  end

  # output remaining dates as a timeframe
  defp chunk_dates({start_date, end_date}) when not is_nil(start_date) do
    {:cont, %{start_date: start_date, end_date: end_date}, []}
  end

  # all remaining dates are inactive, throw them out
  defp chunk_dates(_), do: {:cont, []}

  defp date_field_to_date(%{"date" => date_string}) do
    [year, month, day] = extract_date_parts(date_string)
    Date.from_iso8601!("#{year}-#{month}-#{day}")
  end

  defp apply_additions(dates, additions) do
    additions
    |> Enum.reduce(dates, &add_addition/2)
    |> Enum.sort_by(& &1.start_date, Date)
  end

  defp add_addition(date, acc) do
    cond do
      i = Enum.find_index(acc, &(Date.add(&1.end_date, 1) == date)) ->
        update_in(acc, [Access.at(i), :end_date], fn _ -> date end)

      i = Enum.find_index(acc, &(Date.add(&1.start_date, -1) == date)) ->
        update_in(acc, [Access.at(i), :start_date], fn _ -> date end)

      true ->
        acc ++ [%{start_date: date, end_date: date}]
    end
  end

  # Make sure dates are sorted before we start
  defp merge_adjacent_service_dates([], merged_dates),
    do: Enum.sort_by(merged_dates, & &1.start_date, Date)

  # Only one date for the current service, just add it as-is
  defp merge_adjacent_service_dates([date], []),
    do: merge_adjacent_service_dates([], [date])

  # Last date in the list, prepend it to list
  defp merge_adjacent_service_dates([date], merged_dates),
    do: merge_adjacent_service_dates([], [date | merged_dates])

  defp merge_adjacent_service_dates(
         [
           %{start_date: current_start, end_date: current_end} = current,
           %{start_date: next_start, end_date: next_end} = next | t
         ],
         merged_dates
       ) do
    if Date.add(current_end, 1) == next_start do
      new_date = %{start_date: current_start, end_date: next_end}

      merge_adjacent_service_dates(t, [new_date | merged_dates])
    else
      # Dates aren't adjacent, add current as-is and continue merging
      merge_adjacent_service_dates([next | t], [current | merged_dates])
    end
  end

  defp extract_date_parts(date_string),
    do: Regex.run(~r/^(\d{4})(\d{2})(\d{2})/, date_string, capture: :all_but_first)

  defp revenue_trip?(%{"route_id" => route_id, "trp_is_in_service" => "X"}),
    do: Regex.match?(~r/^\d+_*-.+$/, route_id)

  defp revenue_trip?(_), do: false
end
