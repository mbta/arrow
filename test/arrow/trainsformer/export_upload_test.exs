defmodule Arrow.Trainsformer.ExportUploadTest do
  use Arrow.DataCase, async: true
  import Arrow.Factory
  import Test.Support.Helpers

  alias Arrow.Trainsformer.ExportUpload

  @export_dir "test/support/fixtures/trainsformer"

  setup do
    valid_stops = [
      "NEC-2287",
      "NEC-2276-01",
      "FB-0118-01",
      "FS-0049-S",
      "NEC-1851-03",
      "NEC-1891-02",
      "NEC-1969-04",
      "NEC-2040-01"
    ]

    for stop_id <- valid_stops do
      insert(:gtfs_stop,
        id: stop_id,
        name: stop_id,
        lat: 0,
        lon: 0,
        municipality: "Boston"
      )
    end

    :ok
  end

  describe "extract_data_from_upload/2" do
    @tag export: "valid_export.zip"
    test "extracts data from export", %{export: export} do
      data =
        ExportUpload.extract_data_from_upload(
          %{path: "#{@export_dir}/#{export}"},
          "uid-#{System.unique_integer([:positive])}"
        )

      assert {:ok, {:ok, %ExportUpload{zip_binary: _binary}}} = data
    end

    @tag export: "invalid_csv.zip"
    test "error on invalid csv", %{export: export} do
      data =
        ExportUpload.extract_data_from_upload(
          %{path: "#{@export_dir}/#{export}"},
          "uid-#{System.unique_integer([:positive])}"
        )

      assert {:error, "the error"} = data
    end
  end

  describe "upload_to_s3/3" do
    test "upload is disabled" do
      assert {:ok, "disabled"} = ExportUpload.upload_to_s3("data", "filename", 1)
    end

    test "prepends timestamp and appends disruption_id to filename" do
      reassign_env(:trainsformer_export_storage_enabled?, true)

      result = ExportUpload.upload_to_s3("file content", "export.zip", "12345")

      assert {:ok, path} = result

      assert path =~
               ~r/s3:\/\/mbta-arrow\/trainsformer-export-uploads\/\d+_export_disruption_12345\.zip/
    end
  end

  describe "validate_stop_times_in_gtfs/4" do
    defmodule FakeUnzip do
      def list_entries(_) do
        [%Unzip.Entry{file_name: "stop_times.txt"}]
      end
    end

    defmodule FakeRepo do
      def all(_) do
        ["WR-0329-02", "WR-0325-02", "WR-0264-02"]
      end
    end

    defmodule ImportFakeStops do
      def stream_csv_rows(_, _) do
        rows = [
          %{
            "arrival_time" => "10:26:00",
            "bikes_allowed" => "",
            "departure_time" => "10:26:00",
            "drop_off_type" => "0",
            "nonstandard_track" => "0",
            "pickup_type" => "0",
            "stop_headsign" => "",
            "stop_id" => "morket-borket",
            "stop_sequence" => "140",
            "timepoint" => "1",
            "trip_id" => "ReadWKNDHeadsigns-754204-5530"
          },
          %{
            "arrival_time" => "10:31:00",
            "bikes_allowed" => "",
            "departure_time" => "10:31:00",
            "drop_off_type" => "0",
            "nonstandard_track" => "0",
            "pickup_type" => "0",
            "stop_headsign" => "",
            "stop_id" => "mcdongals",
            "stop_sequence" => "150",
            "timepoint" => "1",
            "trip_id" => "ReadWKNDHeadsigns-754204-5530"
          },
          %{
            "arrival_time" => "10:31:00",
            "bikes_allowed" => "",
            "departure_time" => "10:31:00",
            "drop_off_type" => "0",
            "nonstandard_track" => "0",
            "pickup_type" => "0",
            "stop_headsign" => "",
            "stop_id" => "sbubby",
            "stop_sequence" => "150",
            "timepoint" => "1",
            "trip_id" => "ReadWKNDHeadsigns-754204-5530"
          },
          %{
            "arrival_time" => "10:31:00",
            "bikes_allowed" => "",
            "departure_time" => "10:31:00",
            "drop_off_type" => "0",
            "nonstandard_track" => "0",
            "pickup_type" => "0",
            "stop_headsign" => "",
            "stop_id" => "WR-0329-02",
            "stop_sequence" => "150",
            "timepoint" => "1",
            "trip_id" => "ReadWKNDHeadsigns-754204-5530"
          }
        ]

        Stream.map(rows, & &1)
      end
    end

    defmodule ImportRealStops do
      def stream_csv_rows(_, _) do
        rows = [
          %{
            "arrival_time" => "10:26:00",
            "bikes_allowed" => "",
            "departure_time" => "10:26:00",
            "drop_off_type" => "0",
            "nonstandard_track" => "0",
            "pickup_type" => "0",
            "stop_headsign" => "",
            "stop_id" => "WR-0329-02",
            "stop_sequence" => "140",
            "timepoint" => "1",
            "trip_id" => "Base-772221-5208"
          },
          %{
            "arrival_time" => "10:31:00",
            "bikes_allowed" => "",
            "departure_time" => "10:31:00",
            "drop_off_type" => "0",
            "nonstandard_track" => "0",
            "pickup_type" => "0",
            "stop_headsign" => "",
            "stop_id" => "WR-0325-02",
            "stop_sequence" => "150",
            "timepoint" => "1",
            "trip_id" => "Base-772221-5208"
          },
          %{
            "arrival_time" => "10:31:00",
            "bikes_allowed" => "",
            "departure_time" => "10:31:00",
            "drop_off_type" => "0",
            "nonstandard_track" => "0",
            "pickup_type" => "0",
            "stop_headsign" => "",
            "stop_id" => "WR-0264-02",
            "stop_sequence" => "150",
            "timepoint" => "1",
            "trip_id" => "Base-772221-5208"
          }
        ]

        Stream.map(rows, & &1)
      end
    end

    test "returns ok if all stops in gtfs" do
      assert :ok =
               ExportUpload.validate_stop_times_in_gtfs(
                 %Unzip{},
                 FakeUnzip,
                 ImportRealStops,
                 FakeRepo
               )
    end

    test "returns missing stop if some stops missing from GTFS" do
      assert {:error, {:invalid_export_stops, ["morket-borket", "mcdongals", "sbubby"]}} =
               ExportUpload.validate_stop_times_in_gtfs(
                 %Unzip{},
                 FakeUnzip,
                 ImportFakeStops,
                 FakeRepo
               )
    end
  end
end
