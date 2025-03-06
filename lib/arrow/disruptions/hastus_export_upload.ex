defmodule Arrow.Disruptions.HastusExportUpload do
  alias Arrow.Util

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
  # @spec extract_data_from_upload(%{:path => binary()}) ::
  #         {:ok, {:error, list({error_message, error_details})} | {:ok, versioned_data()}}
  #         | rescued_exception_error()
  def extract_data_from_upload(%{path: zip_path}) do
    with {:ok, zip_file_data} <- File.read(zip_path),
         {:ok, unzipped_file_list} <-
           :zip.unzip(zip_file_data, [{:file_list, @filenames}, {:cwd, @tmp_dir}]),
         {:ok, file_map} <- read_csvs(unzipped_file_list),
         :ok <- validate_export(file_map) do
      {:ok, {:ok, parse_export(file_map)}}
    else
      {:errors, errors} ->
        {:ok, {:errors, errors}}
    end
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

  defp validate_export(file_map) do
    exported_trips = file_map["all_trips.txt"]
    exported_shapes = file_map["all_shapes.txt"]
    exported_routes = file_map["all_routes.txt"]

    errors =
      []
      |> Util.prepend_if(
        :error == validate_trip_shapes(exported_trips, exported_shapes),
        "Trips found with missing/invalid shape IDs."
      )
      |> Util.prepend_if(
        :error == validate_trip_routes(exported_trips, exported_routes),
        "Trips found with missing/invalid route IDs."
      )

    if Enum.any?(errors) do
      {:errors, errors}
    else
      :ok
    end
  end

  defp validate_trip_shapes(exported_trips, exported_shapes) do
    shape_ids = Enum.map(exported_shapes, & &1["shape_id"])

    trips_with_invalid_shapes =
      exported_trips
      |> Enum.filter(&(&1["shape_id"] not in shape_ids))
      |> Enum.map(& &1["trip_id"])

    if Enum.any?(trips_with_invalid_shapes), do: :error, else: :ok
  end

  defp validate_trip_routes(exported_trips, exported_routes) do
    exported_trip_routes =
      exported_trips
      |> Enum.map(fn
        %{"route_id" => route_id} ->
          Enum.find(exported_routes, &(&1["route_id"] == route_id))["route_short_name"]
      end)
      |> Enum.uniq()

    if length(exported_trip_routes) != 1 or Enum.any?(exported_trip_routes, &is_nil/1),
      do: :error,
      else: :ok
  end

  defp get_unzipped_file_path(filename), do: ~c"#{@tmp_dir}/#{filename}"

  defp parse_export(file_map) do
    File.rm_rf!(@tmp_dir) |> IO.inspect()
    file_map
  end
end
