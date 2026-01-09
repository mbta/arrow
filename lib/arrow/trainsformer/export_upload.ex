defmodule Arrow.Trainsformer.ExportUpload do
  import Ecto.Query, only: [from: 2]

  @moduledoc """
  Functions for validating, parsing, and saving Trainsformer export uploads.
  """
  alias Arrow.Gtfs.TimeHelper

  require Logger

  @type t :: %__MODULE__{
          zip_binary: binary(),
          trips_missing_transfers: MapSet.t()
        }

  @enforce_keys [:zip_binary, :trips_missing_transfers]
  defstruct @enforce_keys

  @doc """
  Parses a Trainsformer export and returns extracted data
  """
  @spec extract_data_from_upload(%{path: binary()}) ::
          {:ok,
           {:ok, t()}
           | {:error, String.t()}
           | {:invalid_export_stops, [String.t()]}
           | {:invalid_stop_times,
              [%{trip_id: String.t(), stop_id: String.t(), stop_sequence: String.t()}]}
           | {:trips_missing_transfers, MapSet.t()}}
  def extract_data_from_upload(%{path: zip_path}) do
    zip_bin = Unzip.LocalFile.open(zip_path)

    with {:ok, unzip} <- Unzip.new(zip_bin),
         [] <- validate_csvs(unzip),
         :ok <-
           validate_stop_times_in_gtfs(unzip),
         :ok <- validate_stop_order(unzip) do
      trips_missing_transfers =
        case validate_transfers(unzip) do
          :ok -> MapSet.new()
          {:error, {:trips_missing_transfers, trips}} -> trips
        end

      export_data = %__MODULE__{
        zip_binary: zip_bin,
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
        unzip,
        unzip_module \\ Unzip,
        import_helper \\ Arrow.Gtfs.ImportHelper,
        repo \\ Arrow.Repo
      ) do
    stop_times_file = extract_stop_times(unzip, unzip_module)

    trainsformer_stop_ids =
      import_helper.stream_csv_rows(unzip, stop_times_file)
      |> Stream.uniq_by(fn row -> Map.get(row, "stop_id") end)
      |> Enum.map(fn row -> Map.get(row, "stop_id") end)

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
      :ok
    end
  end

  @spec validate_stop_order(any()) ::
          :ok | {:error, {:invalid_stop_times, any()}} | {:ok, {:error, <<_::160>>}}
  def validate_stop_order(
        unzip,
        unzip_module \\ Unzip,
        import_helper \\ Arrow.Gtfs.ImportHelper
      ) do
    stop_times_file = extract_stop_times(unzip, unzip_module)

    # find trips in stop_times.txt
    trainsformer_trips =
      import_helper.stream_csv_rows(unzip, stop_times_file)
      |> Enum.group_by(fn row -> Map.get(row, "trip_id") end)

    invalid_stop_times =
      Enum.flat_map(trainsformer_trips, &validate_trip(&1))

    if Enum.any?(invalid_stop_times) do
      {:error, {:invalid_stop_times, invalid_stop_times}}
    else
      :ok
    end
  rescue
    e ->
      Logger.warning(
        "Trainsformer.ExportUpload failed to parse zip, message=#{Exception.format(:error, e)}"
      )

      # Must be wrapped in an ok tuple for caller, consume_uploaded_entry/3
      {:ok, {:error, "Could not parse zip."}}
  end

  defp validate_trip({_trip_id, stop_times}) do
    invalid_stop_times_for_trip =
      stop_times
      |> Enum.sort_by(& &1["stop_sequence"])
      # compare two stop_times at a time
      |> Enum.chunk_every(2, 1)
      |> Enum.flat_map(&process_chunk(&1))
      |> Enum.uniq_by(& &1[:stop_id])

    invalid_stop_times_for_trip
  end

  defp process_chunk([stop_time1, stop_time2]) do
    stop_time1_arrival_dur =
      TimeHelper.to_seconds_after_midnight!(Map.get(stop_time1, "arrival_time"))

    stop_time1_departure_dur =
      TimeHelper.to_seconds_after_midnight!(Map.get(stop_time1, "departure_time"))

    stop_time2_arrival_dur =
      TimeHelper.to_seconds_after_midnight!(Map.get(stop_time2, "arrival_time"))

    stop_time2_departure_dur =
      TimeHelper.to_seconds_after_midnight!(Map.get(stop_time2, "departure_time"))

    cond do
      # if the second stop_time has an arrival time before the previous departure, mark as invalid
      compare_durations(stop_time1_departure_dur, stop_time2_arrival_dur) == :gt ->
        [
          create_invalid_stop_time_info(stop_time2)
        ]

      # for either stop, if arrival and departure times are out of order, mark as invalid
      compare_durations(stop_time1_arrival_dur, stop_time1_departure_dur) == :gt ->
        [
          create_invalid_stop_time_info(stop_time1)
        ]

      compare_durations(stop_time2_arrival_dur, stop_time2_departure_dur) == :gt ->
        [
          create_invalid_stop_time_info(stop_time2)
        ]

      true ->
        []
    end
  end

  defp process_chunk([stop_time]) do
    arrival_dur = TimeHelper.to_seconds_after_midnight!(Map.get(stop_time, "arrival_time"))
    departure_dur = TimeHelper.to_seconds_after_midnight!(Map.get(stop_time, "departure_time"))

    if compare_durations(arrival_dur, departure_dur) == :gt do
      [
        create_invalid_stop_time_info(stop_time)
      ]
    else
      []
    end
  end

  defp process_chunk(_) do
    []
  end

  def validate_transfers(unzip, unzip_module \\ Unzip, import_helper \\ Arrow.Gtfs.ImportHelper) do
    [%Unzip.Entry{file_name: stop_times_file}] =
      unzip
      |> unzip_module.list_entries()
      |> Enum.filter(&String.contains?(&1.file_name, "stop_times.txt"))

    transfers_file =
      case unzip
           |> unzip_module.list_entries()
           |> Enum.filter(&String.contains?(&1.file_name, "transfers.txt")) do
        [%Unzip.Entry{file_name: transfers_file}] -> transfers_file
        _ -> nil
      end

    trips_needing_transfers =
      unzip
      |> import_helper.stream_csv_rows(stop_times_file)
      |> Enum.group_by(fn row -> Map.get(row, "trip_id") end, fn row ->
        Map.get(row, "stop_id")
      end)
      |> Enum.reject(fn {_trip_id, stop_ids} ->
        Enum.any?(
          stop_ids,
          &Enum.member?(
            [
              "BNT-0000",
              "NEC-2287",
              "FS-0049-S"
            ],
            &1
          )
        )
      end)
      |> MapSet.new(fn {trip_id, _stop_ids} -> trip_id end)

    trips_with_transfers =
      if transfers_file do
        get_trips_with_transfers_from_file(unzip, transfers_file, import_helper)
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

  defp get_trips_with_transfers_from_file(unzip, transfers_file, import_helper) do
    unzip
    |> import_helper.stream_csv_rows(transfers_file)
    |> Enum.reduce(MapSet.new(), fn row, trip_ids ->
      if Map.get(row, "transfer_type") == "1" and Map.get(row, "from_trip_id") != "" and
           Map.get(row, "to_trip_id") != "" do
        trip_ids
        |> MapSet.put(Map.get(row, "from_trip_id"))
        |> MapSet.put(Map.get(row, "to_trip_id"))
      else
        trip_ids
      end
    end)
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

  defp create_invalid_stop_time_info(stop_time) do
    %{
      trip_id: stop_time["trip_id"],
      stop_id: stop_time["stop_id"],
      stop_sequence: stop_time["stop_sequence"],
      arrival_time: stop_time["arrival_time"],
      departure_time: stop_time["departure_time"]
    }
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

  defp extract_stop_times(unzip, unzip_module) do
    [%Unzip.Entry{file_name: stop_times_file}] =
      unzip
      |> unzip_module.list_entries()
      |> Enum.filter(&String.contains?(&1.file_name, "stop_times.txt"))

    stop_times_file
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

  # returns a list of tuples for problem files:
  #   [{:error, "filename", "the error"}, ...]
  # or if there are no errors:
  #   []
  defp validate_csvs(
         unzip,
         unzip_module \\ Unzip,
         _import_helper \\ Arrow.Gtfs.ImportHelper
       ) do
    unzip
    |> unzip_module.list_entries()
    |> Enum.map(fn entry ->
      try do
        Arrow.Gtfs.ImportHelper.stream_csv_rows(unzip, entry.file_name)
        # Need to run the stream for stream_csv_rows to call CSV.decode! for validation
        |> Stream.run()

        {:ok, entry.file_name, ""}
      rescue
        e ->
          {:error, entry.file_name, Exception.format(:error, e)}
      end
    end)
    |> Enum.filter(fn {result, _file, _error} -> result == :error end)
  end
end
