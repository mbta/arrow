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

  defmodule FakeUnzip do
    def list_entries(_) do
      [%Unzip.Entry{file_name: "stop_times.txt"}, %Unzip.Entry{file_name: "trips.txt"}]
    end
  end

  describe "extract_data_from_upload/1" do
    @tag export: "valid_export.zip"
    test "extracts data from export", %{export: export} do
      data =
        ExportUpload.extract_data_from_upload(%{path: "#{@export_dir}/#{export}"})

      assert {:ok, {:ok, %ExportUpload{zip_binary: _binary}}} = data
    end

    @tag export: "invalid_csv.zip"
    test "error on invalid csv", %{export: export} do
      data =
        ExportUpload.extract_data_from_upload(%{path: "#{@export_dir}/#{export}"})

      assert {:ok,
              [
                {:error, "SPRING2025-SOUTHSS-Weekend-66/stop_times.txt",
                 "** (CSV.RowLengthError) Row 2 has length 9 instead of expected length 11\n\nYou are seeing this error because :validate_row_length has been set to true\n"}
              ]} = data
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

  describe "validate_stop_order/3" do
    defmodule ImportValidStopTimes do
      def stream_csv_rows(_, _) do
        rows = [
          %{
            "arrival_time" => "10:31:00",
            "bikes_allowed" => "",
            "departure_time" => "10:31:00",
            "drop_off_type" => "0",
            "nonstandard_track" => "0",
            "pickup_type" => "0",
            "stop_headsign" => "",
            "stop_id" => "FS-0049-S",
            "stop_sequence" => "0",
            "timepoint" => "1",
            "trip_id" => "October26November2-781218-9733"
          },
          %{
            "arrival_time" => "10:45:00",
            "bikes_allowed" => "",
            "departure_time" => "10:45:00",
            "drop_off_type" => "0",
            "nonstandard_track" => "0",
            "pickup_type" => "0",
            "stop_headsign" => "",
            "stop_id" => "NEC-2287",
            "stop_sequence" => "10",
            "timepoint" => "1",
            "trip_id" => "October26November2-781218-9733"
          },
          %{
            "arrival_time" => "11:01:00",
            "bikes_allowed" => "",
            "departure_time" => "11:01:00",
            "drop_off_type" => "0",
            "nonstandard_track" => "0",
            "pickup_type" => "0",
            "stop_headsign" => "",
            "stop_id" => "NEC-2276-01",
            "stop_sequence" => "20",
            "timepoint" => "1",
            "trip_id" => "October26November2-781218-9733"
          }
        ]

        Stream.map(rows, & &1)
      end
    end

    defmodule ImportInvalidStopTimes do
      def stream_csv_rows(_, _) do
        rows = [
          %{
            "arrival_time" => "10:31:00",
            "bikes_allowed" => "",
            "departure_time" => "10:31:00",
            "drop_off_type" => "0",
            "nonstandard_track" => "0",
            "pickup_type" => "0",
            "stop_headsign" => "",
            "stop_id" => "FS-0049-S",
            "stop_sequence" => "0",
            "timepoint" => "1",
            "trip_id" => "October26November2-781218-9733"
          },
          %{
            "arrival_time" => "10:30:00",
            "bikes_allowed" => "",
            "departure_time" => "10:30:00",
            "drop_off_type" => "0",
            "nonstandard_track" => "0",
            "pickup_type" => "0",
            "stop_headsign" => "",
            "stop_id" => "NEC-2287",
            "stop_sequence" => "10",
            "timepoint" => "1",
            "trip_id" => "October26November2-781218-9733"
          },
          %{
            "arrival_time" => "11:01:00",
            "bikes_allowed" => "",
            "departure_time" => "11:00:00",
            "drop_off_type" => "0",
            "nonstandard_track" => "0",
            "pickup_type" => "0",
            "stop_headsign" => "",
            "stop_id" => "NEC-2276-01",
            "stop_sequence" => "20",
            "timepoint" => "1",
            "trip_id" => "October26November2-781218-9733"
          }
        ]

        Stream.map(rows, & &1)
      end
    end

    test "returns ok if stop time order is valid" do
      assert :ok = ExportUpload.validate_stop_order(%Unzip{}, FakeUnzip, ImportValidStopTimes)
    end

    test "returns invalid stop time info if stop times ordering is invalid" do
      assert {:error,
              {:invalid_stop_times,
               [
                 %{
                   stop_id: "NEC-2287",
                   stop_sequence: "10",
                   arrival_time: "10:30:00",
                   departure_time: "10:30:00",
                   trip_id: "October26November2-781218-9733"
                 },
                 %{
                   stop_id: "NEC-2276-01",
                   stop_sequence: "20",
                   arrival_time: "11:01:00",
                   departure_time: "11:00:00",
                   trip_id: "October26November2-781218-9733"
                 }
               ]}} =
               ExportUpload.validate_stop_order(%Unzip{}, FakeUnzip, ImportInvalidStopTimes)
    end
  end

  describe "validate_one_of_north_south_stations/3" do
    defmodule ImportValidNorthsideStopTimes do
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
            "stop_id" => "BNT-0000",
            "stop_sequence" => "140",
            "timepoint" => "1",
            "trip_id" => "Northside-754204-51"
          },
          %{
            "arrival_time" => "10:31:00",
            "bikes_allowed" => "",
            "departure_time" => "10:31:00",
            "drop_off_type" => "0",
            "nonstandard_track" => "0",
            "pickup_type" => "0",
            "stop_headsign" => "",
            "stop_id" => "WR-0045-S",
            "stop_sequence" => "150",
            "timepoint" => "1",
            "trip_id" => "Northside-754204-51"
          }
        ]

        Stream.map(rows, & &1)
      end
    end

    defmodule ImportValidSouthsideStopTimes do
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
            "stop_id" => "MM-0023-S",
            "stop_sequence" => "140",
            "timepoint" => "1",
            "trip_id" => "Southside-754204-60"
          },
          %{
            "arrival_time" => "10:31:00",
            "bikes_allowed" => "",
            "departure_time" => "10:31:00",
            "drop_off_type" => "0",
            "nonstandard_track" => "0",
            "pickup_type" => "0",
            "stop_headsign" => "",
            "stop_id" => "NEC-2287",
            "stop_sequence" => "150",
            "timepoint" => "1",
            "trip_id" => "Southside-754204-60"
          }
        ]

        Stream.map(rows, & &1)
      end
    end

    defmodule ImportInvalidNorthAndSouthStationsServed do
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
            "stop_id" => "BNT-0000",
            "stop_sequence" => "140",
            "timepoint" => "1",
            "trip_id" => "Northside-754204-51"
          },
          %{
            "arrival_time" => "10:31:00",
            "bikes_allowed" => "",
            "departure_time" => "10:31:00",
            "drop_off_type" => "0",
            "nonstandard_track" => "0",
            "pickup_type" => "0",
            "stop_headsign" => "",
            "stop_id" => "WR-0045-S",
            "stop_sequence" => "150",
            "timepoint" => "1",
            "trip_id" => "Northside-754204-51"
          },
          %{
            "arrival_time" => "10:26:00",
            "bikes_allowed" => "",
            "departure_time" => "10:26:00",
            "drop_off_type" => "0",
            "nonstandard_track" => "0",
            "pickup_type" => "0",
            "stop_headsign" => "",
            "stop_id" => "MM-0023-S",
            "stop_sequence" => "140",
            "timepoint" => "1",
            "trip_id" => "Southside-754204-60"
          },
          %{
            "arrival_time" => "10:31:00",
            "bikes_allowed" => "",
            "departure_time" => "10:31:00",
            "drop_off_type" => "0",
            "nonstandard_track" => "0",
            "pickup_type" => "0",
            "stop_headsign" => "",
            "stop_id" => "NEC-2287",
            "stop_sequence" => "150",
            "timepoint" => "1",
            "trip_id" => "Southside-754204-60"
          }
        ]

        Stream.map(rows, & &1)
      end
    end

    defmodule ImportInvalidNeitherNorthNorSouthStationServed do
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
            "stop_id" => "WR-0045-S",
            "stop_sequence" => "140",
            "timepoint" => "1",
            "trip_id" => "Northside-754204-5533"
          },
          %{
            "arrival_time" => "10:31:00",
            "bikes_allowed" => "",
            "departure_time" => "10:31:00",
            "drop_off_type" => "0",
            "nonstandard_track" => "0",
            "pickup_type" => "0",
            "stop_headsign" => "",
            "stop_id" => "WR-0053-S",
            "stop_sequence" => "150",
            "timepoint" => "1",
            "trip_id" => "Northside-754204-5533"
          }
        ]

        Stream.map(rows, & &1)
      end
    end

    test "returns ok if North but not South Station is served" do
      assert :ok =
               ExportUpload.validate_one_of_north_south_stations(
                 %Unzip{},
                 FakeUnzip,
                 ImportValidNorthsideStopTimes
               )
    end

    test "returns ok if South but not North Station is served" do
      assert :ok =
               ExportUpload.validate_one_of_north_south_stations(
                 %Unzip{},
                 FakeUnzip,
                 ImportValidSouthsideStopTimes
               )
    end

    test "returns error if North and South Stations are both served" do
      assert {:error, :north_and_south_stations_present} =
               ExportUpload.validate_one_of_north_south_stations(
                 %Unzip{},
                 FakeUnzip,
                 ImportInvalidNorthAndSouthStationsServed
               )
    end

    test "returns error if neither North nor South Station is served" do
      assert {:error, :north_and_south_stations_not_present} =
               ExportUpload.validate_one_of_north_south_stations(
                 %Unzip{},
                 FakeUnzip,
                 ImportInvalidNeitherNorthNorSouthStationServed
               )
    end
  end

  describe "validate_one_or_all_routes_from_one_side/3" do
    defmodule ImportValidNorthsideTripsAllRoutes do
      def stream_csv_rows(_, _) do
        rows = [
          %{
            "bikes_allowed" => "1",
            "direction_id" => "1",
            "event_time" => "",
            "route_id" => "CR-Newburyport",
            "service_id" => "FALL 2025-SOUTHWKD-Weekday-11A",
            "shape_id" => "9850001",
            "trip_headsign" => "North Station",
            "trip_id" => "Weekday-789267-102",
            "trip_short_name" => "102"
          },
          %{
            "bikes_allowed" => "1",
            "direction_id" => "1",
            "event_time" => "",
            "route_id" => "CR-Haverhill",
            "service_id" => "FALL 2025-SOUTHWKD-Weekday-11A",
            "shape_id" => "9850002",
            "trip_headsign" => "North Station",
            "trip_id" => "Weekday-789267-202",
            "trip_short_name" => "202"
          },
          %{
            "bikes_allowed" => "1",
            "direction_id" => "1",
            "event_time" => "",
            "route_id" => "CR-Lowell",
            "service_id" => "FALL 2025-SOUTHWKD-Weekday-11A",
            "shape_id" => "9850003",
            "trip_headsign" => "North Station",
            "trip_id" => "Weekday-789267-302",
            "trip_short_name" => "302"
          },
          %{
            "bikes_allowed" => "1",
            "direction_id" => "1",
            "event_time" => "",
            "route_id" => "CR-Fitchburg",
            "service_id" => "FALL 2025-SOUTHWKD-Weekday-11A",
            "shape_id" => "9850004",
            "trip_headsign" => "North Station",
            "trip_id" => "Weekday-789267-402",
            "trip_short_name" => "402"
          }
        ]

        Stream.map(rows, & &1)
      end
    end

    defmodule ImportValidNorthsideTripsOneRoute do
      def stream_csv_rows(_, _) do
        rows = [
          %{
            "bikes_allowed" => "1",
            "direction_id" => "1",
            "event_time" => "",
            "route_id" => "CR-Newburyport",
            "service_id" => "FALL 2025-SOUTHWKD-Weekday-11A",
            "shape_id" => "9850001",
            "trip_headsign" => "North Station",
            "trip_id" => "Weekday-789267-102",
            "trip_short_name" => "102"
          },
          %{
            "bikes_allowed" => "1",
            "direction_id" => "1",
            "event_time" => "",
            "route_id" => "CR-Newburyport",
            "service_id" => "FALL 2025-SOUTHWKD-Weekday-11A",
            "shape_id" => "9850001",
            "trip_headsign" => "North Station",
            "trip_id" => "Weekday-789267-104",
            "trip_short_name" => "104"
          },
          %{
            "bikes_allowed" => "1",
            "direction_id" => "0",
            "event_time" => "",
            "route_id" => "CR-Newburyport",
            "service_id" => "FALL 2025-SOUTHWKD-Weekday-11A",
            "shape_id" => "9850003",
            "trip_headsign" => "Rockport",
            "trip_id" => "Weekday-789267-101",
            "trip_short_name" => "101"
          },
          %{
            "bikes_allowed" => "1",
            "direction_id" => "0",
            "event_time" => "",
            "route_id" => "CR-Newburyport",
            "service_id" => "FALL 2025-SOUTHWKD-Weekday-11A",
            "shape_id" => "9850002",
            "trip_headsign" => "Rockport",
            "trip_id" => "Weekday-789267-103",
            "trip_short_name" => "103"
          }
        ]

        Stream.map(rows, & &1)
      end
    end

    # CR-Fitchburg and CR-Lowell missing:
    defmodule ImportInvalidNorthsideTripsMissingRoute do
      def stream_csv_rows(_, _) do
        rows = [
          %{
            "bikes_allowed" => "1",
            "direction_id" => "1",
            "event_time" => "",
            "route_id" => "CR-Newburyport",
            "service_id" => "FALL 2025-SOUTHWKD-Weekday-11A",
            "shape_id" => "9850001",
            "trip_headsign" => "North Station",
            "trip_id" => "Weekday-789267-102",
            "trip_short_name" => "102"
          },
          %{
            "bikes_allowed" => "1",
            "direction_id" => "1",
            "event_time" => "",
            "route_id" => "CR-Haverhill",
            "service_id" => "FALL 2025-SOUTHWKD-Weekday-11A",
            "shape_id" => "9850002",
            "trip_headsign" => "North Station",
            "trip_id" => "Weekday-789267-202",
            "trip_short_name" => "202"
          }
        ]

        Stream.map(rows, & &1)
      end
    end

    defmodule ImportValidSingleRouteNeitherSide do
      def stream_csv_rows(_, _) do
        rows = [
          %{
            "bikes_allowed" => "1",
            "direction_id" => "1",
            "event_time" => "",
            "route_id" => "CR-Foxboro",
            "service_id" => "FALL 2025-SOUTHWKD-Weekday-11A",
            "shape_id" => "9850009",
            "trip_headsign" => "South Station via Foxboro",
            "trip_id" => "Weekday-789267-902",
            "trip_short_name" => "902"
          },
          %{
            "bikes_allowed" => "1",
            "direction_id" => "0",
            "event_time" => "",
            "route_id" => "CR-Foxboro",
            "service_id" => "FALL 2025-SOUTHWKD-Weekday-11A",
            "shape_id" => "9850008",
            "trip_headsign" => "Providence via Foxboro",
            "trip_id" => "Weekday-789267-103",
            "trip_short_name" => "103"
          }
        ]

        Stream.map(rows, & &1)
      end
    end

    defmodule ImportInvalidRoutesNeitherSide do
      def stream_csv_rows(_, _) do
        rows = [
          %{
            "bikes_allowed" => "1",
            "direction_id" => "1",
            "event_time" => "",
            "route_id" => "CR-Foxboro",
            "service_id" => "FALL 2025-SOUTHWKD-Weekday-11A",
            "shape_id" => "9850009",
            "trip_headsign" => "South Station via Foxboro",
            "trip_id" => "Weekday-789267-902",
            "trip_short_name" => "902"
          },
          %{
            "bikes_allowed" => "1",
            "direction_id" => "0",
            "event_time" => "",
            "route_id" => "CR-Nowhere",
            "service_id" => "FALL 2025-SOUTHWKD-Weekday-11A",
            "shape_id" => "9850998",
            "trip_headsign" => "Nowhere",
            "trip_id" => "Weekday-789267-999",
            "trip_short_name" => "999"
          }
        ]

        Stream.map(rows, & &1)
      end
    end

    test "returns ok if all Northside routes have a trip" do
      assert :ok =
               ExportUpload.validate_one_or_all_routes_from_one_side(
                 %Unzip{},
                 FakeUnzip,
                 ImportValidNorthsideTripsAllRoutes
               )
    end

    test "returns ok if exactly one Northside route has a trip" do
      assert :ok =
               ExportUpload.validate_one_or_all_routes_from_one_side(
                 %Unzip{},
                 FakeUnzip,
                 ImportValidNorthsideTripsOneRoute
               )
    end

    test "returns error if more than one but not all Northside routes have a trip" do
      assert {:error, {:missing_routes, ["CR-Fitchburg", "CR-Lowell"]}} =
               ExportUpload.validate_one_or_all_routes_from_one_side(
                 %Unzip{},
                 FakeUnzip,
                 ImportInvalidNorthsideTripsMissingRoute
               )
    end

    test "returns ok for a single route not in either side's required list" do
      assert :ok =
               ExportUpload.validate_one_or_all_routes_from_one_side(
                 %Unzip{},
                 FakeUnzip,
                 ImportValidSingleRouteNeitherSide
               )
    end

    test "returns error for multiple routes not in either side's required list" do
      assert {:error, {:invalid_routes, ["CR-Foxboro", "CR-Nowhere"]}} =
               ExportUpload.validate_one_or_all_routes_from_one_side(
                 %Unzip{},
                 FakeUnzip,
                 ImportInvalidRoutesNeitherSide
               )
    end
  end

  describe "validate_transfers/3" do
    defmodule FakeUnzipWithTransfers do
      def list_entries(_) do
        [%Unzip.Entry{file_name: "stop_times.txt"}, %Unzip.Entry{file_name: "transfers.txt"}]
      end
    end

    defmodule ImportWithTransfers do
      def stream_csv_rows(_, "stop_times.txt") do
        [
          %{
            "arrival_time" => "",
            "bikes_allowed" => "",
            "departure_time" => "10:00:00",
            "drop_off_type" => "0",
            "nonstandard_track" => "0",
            "pickup_type" => "0",
            "stop_headsign" => "",
            "stop_id" => "BNT-0000",
            "stop_sequence" => "10",
            "timepoint" => "1",
            "trip_id" => "1234"
          },
          %{
            "arrival_time" => "10:30:00",
            "bikes_allowed" => "",
            "departure_time" => "",
            "drop_off_type" => "0",
            "nonstandard_track" => "0",
            "pickup_type" => "0",
            "stop_headsign" => "",
            "stop_id" => "ER-0183",
            "stop_sequence" => "20",
            "timepoint" => "1",
            "trip_id" => "1234"
          },
          %{
            "arrival_time" => "",
            "bikes_allowed" => "",
            "departure_time" => "10:35:00",
            "drop_off_type" => "0",
            "nonstandard_track" => "0",
            "pickup_type" => "0",
            "stop_headsign" => "",
            "stop_id" => "ER-0183",
            "stop_sequence" => "10",
            "timepoint" => "1",
            "trip_id" => "5678"
          },
          %{
            "arrival_time" => "11:00:00",
            "bikes_allowed" => "",
            "departure_time" => "",
            "drop_off_type" => "0",
            "nonstandard_track" => "0",
            "pickup_type" => "0",
            "stop_headsign" => "",
            "stop_id" => "ER-0362",
            "stop_sequence" => "20",
            "timepoint" => "1",
            "trip_id" => "5678"
          }
        ]
      end

      def stream_csv_rows(_, "transfers.txt") do
        [
          %{
            "from_stop_id" => "ER-0183",
            "to_stop_id" => "ER-0183",
            "from_trip_id" => "1234",
            "to_trip_id" => "5678",
            "transfer_type" => "1"
          }
        ]
      end
    end

    defmodule ImportMissingTransfers do
      def stream_csv_rows(_, "stop_times.txt") do
        [
          %{
            "arrival_time" => "",
            "bikes_allowed" => "",
            "departure_time" => "10:00:00",
            "drop_off_type" => "0",
            "nonstandard_track" => "0",
            "pickup_type" => "0",
            "stop_headsign" => "",
            "stop_id" => "BNT-0000",
            "stop_sequence" => "10",
            "timepoint" => "1",
            "trip_id" => "1234"
          },
          %{
            "arrival_time" => "10:30:00",
            "bikes_allowed" => "",
            "departure_time" => "",
            "drop_off_type" => "0",
            "nonstandard_track" => "0",
            "pickup_type" => "0",
            "stop_headsign" => "",
            "stop_id" => "ER-0183",
            "stop_sequence" => "20",
            "timepoint" => "1",
            "trip_id" => "1234"
          },
          %{
            "arrival_time" => "",
            "bikes_allowed" => "",
            "departure_time" => "10:35:00",
            "drop_off_type" => "0",
            "nonstandard_track" => "0",
            "pickup_type" => "0",
            "stop_headsign" => "",
            "stop_id" => "ER-0183",
            "stop_sequence" => "10",
            "timepoint" => "1",
            "trip_id" => "5678"
          },
          %{
            "arrival_time" => "11:00:00",
            "bikes_allowed" => "",
            "departure_time" => "",
            "drop_off_type" => "0",
            "nonstandard_track" => "0",
            "pickup_type" => "0",
            "stop_headsign" => "",
            "stop_id" => "ER-0362",
            "stop_sequence" => "20",
            "timepoint" => "1",
            "trip_id" => "5678"
          }
        ]
      end

      def stream_csv_rows(_, "transfers.txt"), do: []
    end

    test "returns ok if all appopriate trips have transfers" do
      assert :ok =
               ExportUpload.validate_transfers(
                 %Unzip{},
                 FakeUnzipWithTransfers,
                 ImportWithTransfers
               )
    end

    test "returns an error if any transfers are missing" do
      expected_trips_with_missing_transfers = MapSet.new(["5678"])

      assert {:error, {:trips_missing_transfers, ^expected_trips_with_missing_transfers}} =
               ExportUpload.validate_transfers(
                 %Unzip{},
                 FakeUnzipWithTransfers,
                 ImportMissingTransfers
               )
    end
  end
end
