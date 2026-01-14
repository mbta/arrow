defmodule Arrow.Trainsformer.ExportUpload do
  import Ecto.Query, only: [from: 2]

  @moduledoc """
  Functions for validating, parsing, and saving Trainsformer export uploads.
  """
  alias Arrow.Gtfs.TimeHelper

  require Logger

  @type t :: %__MODULE__{
          zip_binary: binary(),
          one_of_north_south_stations: :ok | :both | :neither,
          routes: [String.t()],
          services: [String.t()],
          missing_routes: [String.t()],
          invalid_routes: [String.t()],
          trips_missing_transfers: MapSet.t()
        }

  @enforce_keys [
    :zip_binary,
    :one_of_north_south_stations,
    :routes,
    :services,
    :missing_routes,
    :invalid_routes,
    :trips_missing_transfers
  ]
  defstruct @enforce_keys

  @type transfer ::
          %{
            transfer_type: String.t(),
            from_trip_id: String.t(),
            to_trip_id: String.t()
          }

  @type trainsformer_stop_time :: %{
          trip_id: String.t(),
          stop_id: String.t(),
          stop_sequence: String.t(),
          arrival_time: String.t(),
          departure_time: String.t()
        }

  @type trainsformer_trip :: %{
          trip_id: String.t(),
          service_id: String.t(),
          route_id: String.t()
        }

  @doc """
  Parses a Trainsformer export and returns extracted data
  """
  @spec extract_data_from_upload(%{path: binary()}) ::
          {:ok,
           {:ok, t()}
           | {:error, {:trips_missing_transfers, [String.t()]}}
           | {:error, {:invalid_stop_times, any()}}}
          | {:error, {:invalid_export_stops, [String.t()]}}
  def extract_data_from_upload(
        %{path: zip_path},
        unzip_module \\ Unzip,
        import_helper \\ Arrow.Gtfs.ImportHelper
      ) do
    zip_bin = Unzip.LocalFile.open(zip_path)

    with {:ok, unzip} <- Unzip.new(zip_bin),
         {:ok, %{trips: trips, stop_times: stop_times, transfers: transfers}} <-
           validate_csvs(unzip, unzip_module, import_helper),
         {:ok, stop_ids} <-
           validate_stop_times_in_gtfs(stop_times),
         :ok <- validate_stop_order(stop_times),
         {:ok, zip_bin} <- File.read(zip_path) do
      one_of_north_south_stations = validate_one_of_north_south_stations(stop_ids)
      {missing_routes, invalid_routes} = validate_one_or_all_routes_from_one_side(trips)

      trips_missing_transfers =
        case validate_transfers(transfers, stop_times) do
          :ok -> MapSet.new()
          {:error, {:trips_missing_transfers, invalid_trips}} -> invalid_trips
        end

      {routes, services} =
        trips
        |> Enum.reduce(
          {MapSet.new(), MapSet.new()},
          fn trip, {routes, services} ->
            {MapSet.put(routes, trip.route_id), MapSet.put(services, trip.service_id)}
          end
        )

      current_date_string = Date.to_iso8601(Date.utc_today())

      service_maps =
        Enum.map(services, fn service_id ->
          %{
            "name" => service_id,
            "service_dates" => [
              %{
                "service_id" => service_id,
                "start_date" => current_date_string,
                "end_date" => current_date_string
              }
            ]
          }
        end)

      route_maps =
        Enum.map(routes, fn route_id -> %{"route_id" => route_id} end)

      export_data = %__MODULE__{
        zip_binary: zip_bin,
        one_of_north_south_stations: one_of_north_south_stations,
        missing_routes: missing_routes,
        invalid_routes: invalid_routes,
        routes: route_maps,
        services: service_maps,
        trips_missing_transfers: trips_missing_transfers
      }

      {:ok, {:ok, export_data}}
    else
      errors ->
        {:ok, errors}
    end
  rescue
    e ->
      # Must be wrapped in an ok tuple for caller, consume_uploaded_entry/3
      {:ok, {:error, "Could not parse zip, message=#{Exception.format(:error, e)}"}}
  end

  def validate_stop_times_in_gtfs(
        stop_times,
        repo \\ Arrow.Repo
      ) do
    trainsformer_stop_ids =
      stop_times
      |> Enum.uniq_by(& &1.stop_id)
      |> Enum.map(& &1.stop_id)

    gtfs_stop_ids =
      MapSet.new(
        repo.all(
          from s in Arrow.Gtfs.Stop,
            where: s.id in ^trainsformer_stop_ids,
            select: s.id
        )
      )

    stops_missing_from_gtfs =
      Enum.filter(trainsformer_stop_ids, fn stop -> !MapSet.member?(gtfs_stop_ids, stop) end)

    if Enum.any?(stops_missing_from_gtfs) do
      {:error, {:invalid_export_stops, stops_missing_from_gtfs}}
    else
      {:ok, trainsformer_stop_ids}
    end
  end

  @spec validate_stop_order(any()) ::
          :ok | {:error, {:invalid_stop_times, any()}} | {:ok, {:error, <<_::160>>}}
  def validate_stop_order(stop_times) do
    trainsformer_trips =
      Enum.group_by(stop_times, & &1.trip_id)

    invalid_stop_times =
      Enum.flat_map(trainsformer_trips, &validate_trip(&1))

    if Enum.any?(invalid_stop_times) do
      {:error, {:invalid_stop_times, invalid_stop_times}}
    else
      :ok
    end
  end

  defp validate_trip({_trip_id, stop_times}) do
    invalid_stop_times_for_trip =
      stop_times
      |> Enum.sort_by(& &1.stop_sequence)
      # compare two stop_times at a time
      |> Enum.chunk_every(2, 1)
      |> Enum.flat_map(&process_chunk(&1))
      |> Enum.uniq_by(& &1.stop_id)

    invalid_stop_times_for_trip
  end

  defp process_chunk([stop_time1, stop_time2]) do
    stop_time1_arrival_dur =
      TimeHelper.to_seconds_after_midnight!(stop_time1.arrival_time)

    stop_time1_departure_dur =
      TimeHelper.to_seconds_after_midnight!(stop_time1.departure_time)

    stop_time2_arrival_dur =
      TimeHelper.to_seconds_after_midnight!(stop_time2.arrival_time)

    stop_time2_departure_dur =
      TimeHelper.to_seconds_after_midnight!(stop_time2.departure_time)

    cond do
      # if the second stop_time has an arrival time before the previous departure, mark as invalid
      compare_durations(stop_time1_departure_dur, stop_time2_arrival_dur) == :gt ->
        [
          stop_time2
        ]

      # for either stop, if arrival and departure times are out of order, mark as invalid
      compare_durations(stop_time1_arrival_dur, stop_time1_departure_dur) == :gt ->
        [
          stop_time1
        ]

      compare_durations(stop_time2_arrival_dur, stop_time2_departure_dur) == :gt ->
        [
          stop_time2
        ]

      true ->
        []
    end
  end

  defp process_chunk([stop_time]) do
    arrival_dur = TimeHelper.to_seconds_after_midnight!(stop_time.arrival_time)
    departure_dur = TimeHelper.to_seconds_after_midnight!(stop_time.departure_time)

    if compare_durations(arrival_dur, departure_dur) == :gt do
      [
        stop_time
      ]
    else
      []
    end
  end

  defp process_chunk(_) do
    []
  end

  def validate_transfers(transfers, stop_times) do
    trips_needing_transfers =
      stop_times
      |> Enum.group_by(& &1.trip_id, & &1.stop_id)
      |> Enum.reject(fn {_trip_id, stop_ids} ->
        Enum.any?(
          stop_ids,
          &Enum.member?(
            [
              # North Station
              "BNT-0000",
              # South Station
              "NEC-2287",
              # Foxboro
              "FS-0049-S"
            ],
            &1
          )
        )
      end)
      |> MapSet.new(fn {trip_id, _stop_ids} -> trip_id end)

    trips_with_transfers =
      if transfers != [] do
        get_trips_with_transfers_from_file(transfers)
      else
        MapSet.new()
      end

    trips_needing_transfers_without_transfers =
      MapSet.difference(trips_needing_transfers, trips_with_transfers)

    if Enum.empty?(trips_needing_transfers_without_transfers) do
      :ok
    else
      {:error, {:trips_missing_transfers, trips_needing_transfers_without_transfers}}
    end
  end

  defp get_trips_with_transfers_from_file(transfers) do
    transfers
    |> Enum.reduce(MapSet.new(), fn transfer, trip_ids ->
      if transfer.transfer_type == "1" and transfer.from_trip_id != "" and
           transfer.to_trip_id != "" do
        trip_ids
        |> MapSet.put(transfer.from_trip_id)
        |> MapSet.put(transfer.to_trip_id)
      else
        trip_ids
      end
    end)
  end

  @spec validate_one_of_north_south_stations(any()) ::
          :ok
          | :both
          | :neither
  def validate_one_of_north_south_stations(trainsformer_stop_ids) do
    north_station_served = Enum.member?(trainsformer_stop_ids, "BNT-0000")
    south_station_served = Enum.member?(trainsformer_stop_ids, "NEC-2287")

    cond do
      north_station_served and south_station_served ->
        :both

      not north_station_served and not south_station_served ->
        :neither

      true ->
        :ok
    end
  end

  @southside_route_ids [
    "CR-Fairmount",
    "CR-Franklin",
    "CR-Greenbush",
    "CR-Kingston",
    "CR-Needham",
    "CR-NewBedford",
    "CR-Providence",
    "CR-Worcester"
  ]

  @northside_route_ids ["CR-Fitchburg", "CR-Haverhill", "CR-Lowell", "CR-Newburyport"]

  # We require all of the routes from one side to be present,
  # or a single route.
  # Returns {missing_routes, invalid_routes}
  @spec validate_one_or_all_routes_from_one_side(any()) ::
          {[String.t()], [String.t()]}
  def validate_one_or_all_routes_from_one_side(trips) do
    trainsformer_route_ids =
      trips
      |> Enum.uniq_by(& &1.route_id)
      |> Enum.map(& &1.route_id)

    southside_routes_missing =
      Enum.filter(@southside_route_ids, fn route ->
        !Enum.member?(trainsformer_route_ids, route)
      end)

    num_southside_routes_missing = length(southside_routes_missing)

    northside_routes_missing =
      Enum.filter(@northside_route_ids, fn route ->
        !Enum.member?(trainsformer_route_ids, route)
      end)

    num_northside_routes_missing = length(northside_routes_missing)

    cond do
      length(trainsformer_route_ids) == 1 ->
        {[], []}

      num_southside_routes_missing == 0 ->
        {[], []}

      num_northside_routes_missing == 0 ->
        {[], []}

      num_southside_routes_missing < length(@southside_route_ids) ->
        {southside_routes_missing, []}

      num_northside_routes_missing < length(@northside_route_ids) ->
        {northside_routes_missing, []}

      # More than one route, and they all aren't in @northside_route_ids or @southside_route_ids
      true ->
        {[], trainsformer_route_ids}
    end
  end

  @spec upload_to_s3(binary(), String.t(), String.t() | integer()) ::
          {:ok, String.t()} | {:error, term()}
  def upload_to_s3(file_data, filename, disruption_id) do
    if Application.fetch_env!(:arrow, :trainsformer_export_storage_enabled?) do
      timestamp = System.system_time(:second)
      basename = Path.basename(filename, Path.extname(filename))
      ext = Path.extname(filename)
      modified_filename = "#{timestamp}_#{basename}_disruption_#{disruption_id}#{ext}"
      do_upload(file_data, modified_filename)
    else
      {:ok, "disabled"}
    end
  end

  defp compare_durations(duration1, duration2) do
    cond do
      duration1 > duration2 ->
        :gt

      duration1 < duration2 ->
        :lt

      true ->
        :eq
    end
  end

  defp do_upload(file_data, filename) do
    s3_bucket = Application.fetch_env!(:arrow, :trainsformer_export_storage_bucket)
    path = get_upload_path(filename)

    upload_op =
      ExAws.S3.put_object(s3_bucket, path, file_data,
        content_type: "application/zip",
        if_none_match: "*"
      )

    {mod, fun} = Application.fetch_env!(:arrow, :trainsformer_export_storage_request_fn)

    case apply(mod, fun, [upload_op]) do
      {:ok, _} -> {:ok, Path.join(["s3://", s3_bucket, path])}
      {:error, _} = error -> error
    end
  end

  defp get_upload_path(filename) do
    prefix_env = Application.get_env(:arrow, :trainsformer_export_storage_prefix_env)
    s3_prefix = Application.fetch_env!(:arrow, :trainsformer_export_storage_prefix)

    username_prefix =
      if Application.fetch_env!(:arrow, :use_username_prefix?) do
        {username, _} = System.cmd("whoami", [])
        String.trim(username)
      end

    [prefix_env, username_prefix, s3_prefix, filename]
    |> Enum.reject(&is_nil/1)
    |> Path.join()
  end

  defp do_validate_csv(entry, errors, result, base_name, unzip, import_helper) do
    try do
      rows =
        unzip
        |> import_helper.stream_csv_rows(entry.file_name)
        # Need to run the stream for stream_csv_rows to call CSV.decode! for validation
        |> Stream.map(&parse_row(base_name, &1))
        |> Enum.to_list()

      data_type =
        case base_name do
          "trips.txt" -> :trips
          "transfers.txt" -> :transfers
          "stop_times.txt" -> :stop_times
        end

      {errors, Map.put(result, data_type, rows)}
    rescue
      e ->
        {[
           {:error, entry.file_name, Exception.format(:error, e)}
           | errors
         ], result}
    end
  end

  @files_to_parse ["trips.txt", "transfers.txt", "stop_times.txt"]

  @spec validate_csvs(Unzip, module(), module()) ::
          {:ok,
           %{
             trips: [trainsformer_trip()],
             stop_times: [trainsformer_stop_time()],
             transfers: [transfer()]
           }}
          | {:error, String.t()}
  defp validate_csvs(
         unzip,
         unzip_module,
         import_helper
       ) do
    {errors, result} =
      unzip
      |> unzip_module.list_entries()
      |> Enum.reduce({[], %{trips: [], stop_times: [], transfers: []}}, fn entry,
                                                                           {errors, result} ->
        base_name = Path.basename(entry.file_name)

        if base_name in @files_to_parse do
          do_validate_csv(entry, errors, result, base_name, unzip, import_helper)
        else
          {errors, result}
        end
      end)

    case errors do
      [] -> {:ok, result}
      _ -> errors
    end
  end

  defp parse_row("trips.txt", row) do
    %{
      trip_id: row["trip_id"],
      service_id: row["service_id"],
      route_id: row["route_id"]
    }
  end

  defp parse_row("stop_times.txt", stop_time) do
    %{
      trip_id: stop_time["trip_id"],
      stop_id: stop_time["stop_id"],
      stop_sequence: stop_time["stop_sequence"],
      arrival_time: stop_time["arrival_time"],
      departure_time: stop_time["departure_time"]
    }
  end

  defp parse_row("transfers.txt", transfer) do
    %{
      transfer_type: transfer["transfer_type"],
      from_trip_id: transfer["from_trip_id"],
      to_trip_id: transfer["to_trip_id"]
    }
  end
end
