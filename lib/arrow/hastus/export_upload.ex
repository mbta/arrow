defmodule Arrow.Hastus.ExportUpload do
  import Ecto.Query, only: [from: 2]

  alias Arrow.Hastus.{Service, ServiceDate}

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

  @tmp_dir ~c"tmp/hastus"

  @doc """
  Parses a HASTUS export and returns a list of data
  Includes a rescue clause to catch errors while parsing user-provided data
  """
  @spec extract_data_from_upload(%{:path => binary()}) ::
          {:ok, {:errors, list(error_message)} | {:ok, list(map())}} | rescued_exception_error()
  def extract_data_from_upload(%{path: zip_path}) do
    with {:ok, zip_file_data} <- File.read(zip_path),
         {:ok, unzipped_file_list} <-
           :zip.unzip(zip_file_data, [{:file_list, @filenames}, {:cwd, @tmp_dir}]),
         {:ok, file_map} <- read_csvs(unzipped_file_list),
         revenue_trips <- Stream.filter(file_map["all_trips.txt"], &revenue_trip?/1),
         :ok <- validate_trip_shapes(revenue_trips, file_map["all_shapes.txt"]),
         {:ok, route} <- infer_route(revenue_trips, file_map["all_stop_times.txt"]) do
      {:ok, {:ok, parse_export(file_map), route}}
    else
      {:errors, errors} ->
        {:ok, {:errors, errors}}
    end
  rescue
    e ->
      Logger.warning(
        "Hastus.ExportUpload failed to parse zip, message=#{Exception.format(:error, e, __STACKTRACE__)}"
      )

      # Must be wrapped in an ok tuple for caller, consume_uploaded_entry/3
      {:ok, {:errors, ["Could not parse zip."]}}
  end

  defp read_csvs(unzip) do
    missing_files = Enum.filter(@filenames, &(get_unzipped_file_path(&1) not in unzip))

    if Enum.any?(missing_files) do
      {:errors,
       ["The following files are missing from the export: #{Enum.join(missing_files, ", ")}"]}
    else
      map =
        @filenames
        |> Enum.map(fn filename ->
          data =
            filename
            |> get_unzipped_file_path()
            |> File.stream!()
            |> CSV.decode!(headers: true)

          {to_string(filename), data}
        end)
        |> Map.new()

      {:ok, map}
    end
  end

  defp validate_trip_shapes(revenue_trips, exported_shapes) do
    shape_ids = Enum.map(exported_shapes, & &1["shape_id"])

    trips_with_invalid_shapes =
      revenue_trips
      |> Stream.filter(&(&1["shape_id"] not in shape_ids))
      |> Stream.map(& &1["trip_id"])

    if Enum.any?(trips_with_invalid_shapes), do: :error, else: :ok
  end

  defp infer_route(revenue_trips, exported_stop_times) do
    revenue_trip_ids = Enum.map(revenue_trips, & &1["trip_id"])

    exported_stop_ids =
      exported_stop_times
      |> Enum.filter(&(&1["trip_id"] in revenue_trip_ids))
      |> Enum.map(& &1["stop_id"])
      |> Enum.uniq()

    routes =
      Arrow.Repo.all(
        from st in Arrow.Gtfs.StopTime,
          where: st.stop_id in ^exported_stop_ids,
          join: t in Arrow.Gtfs.Trip,
          on: t.id == st.trip_id,
          select: t.route_id,
          distinct: t.route_id
      )

    case routes do
      [route] -> {:ok, route}
      ["Green-B", "Green-C", "Green-D", "Green-E"] -> {:ok, "Green"}
      _ -> {:errors, ["Export contains more than one route"]}
    end
  end

  defp get_unzipped_file_path(filename), do: ~c"#{@tmp_dir}/#{filename}"

  defp parse_export(%{"all_calendar.txt" => calendar, "all_calendar_dates.txt" => calendar_dates}) do
    imported_service =
      Enum.reduce(Stream.concat(calendar, calendar_dates), [], fn
        # calendar rows
        %{
          "service_id" => service_id,
          "start_date" => start_date_string,
          "end_date" => end_date_string
        },
        acc ->
          [start_year, start_month, start_day] = extract_date_parts(start_date_string)
          [end_year, end_month, end_day] = extract_date_parts(end_date_string)

          date = %ServiceDate{
            start_date: Date.from_iso8601!("#{start_year}-#{start_month}-#{start_day}"),
            end_date: Date.from_iso8601!("#{end_year}-#{end_month}-#{end_day}")
          }

          add_or_update_list(acc, service_id, date)

        # calendar_dates rows
        %{"service_id" => service_id, "date" => date_string}, acc ->
          [year, month, day] = extract_date_parts(date_string)

          date = %ServiceDate{
            start_date: Date.from_iso8601!("#{year}-#{month}-#{day}"),
            end_date: Date.from_iso8601!("#{year}-#{month}-#{day}")
          }

          add_or_update_list(acc, service_id, date)
      end)

    _ = File.rm_rf!(@tmp_dir)

    imported_service
  end

  defp extract_date_parts(date_string),
    do: Regex.run(~r/^(\d{4})(\d{2})(\d{2})/, date_string, capture: :all_but_first)

  defp add_or_update_list([], new_service_id, new_date),
    do: [%Service{service_id: new_service_id, service_dates: [new_date]}]

  defp add_or_update_list(
         [h = %{service_id: service_id, service_dates: existing_dates} | t],
         service_id,
         new_date
       ),
       do: [%{h | service_dates: existing_dates ++ [new_date]} | t]

  defp add_or_update_list([h | t], new_service_id, new_date),
    do: [h | add_or_update_list(t, new_service_id, new_date)]

  defp revenue_trip?(%{"route_id" => route_id}), do: Regex.match?(~r/^\d+_*-.+$/, route_id)
end
