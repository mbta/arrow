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

      assert {:ok,
              {:ok,
               %ExportUpload{
                 zip_binary: _binary,
                 services: [%{"name" => "SPRING2025-SOUTHSS-Weekend-66"}],
                 routes: [%{"route_id" => "CR-Foxboro"}]
               }}} = data
    end

    @tag export: "valid_export.zip"
    test "fails on previously used service ids in export", %{export: export} do
      Arrow.Repo.insert(%Arrow.Trainsformer.Service{name: "SPRING2025-SOUTHSS-Weekend-66"})

      data =
        ExportUpload.extract_data_from_upload(%{path: "#{@export_dir}/#{export}"})

      assert {:ok, {:error, {:existing_service_id, ["SPRING2025-SOUTHSS-Weekend-66"]}}} = data
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

  describe "download_from_s3/1" do
    test "download is disabled" do
      assert {:error, :disabled} = ExportUpload.download_from_s3("filename")
    end

    test "retrieves file" do
      reassign_env(:trainsformer_export_storage_enabled?, true)

      result =
        ExportUpload.download_from_s3("s3://test-bucket/trainsformer-export-uploads/export.zip")

      assert {:ok, "foo"} = result
    end
  end

  describe "validate_stop_ids_in_gtfs/4" do
    defmodule FakeRepo do
      def all(_) do
        ["WR-0329-02", "WR-0325-02", "WR-0264-02"]
      end
    end

    test "returns ok if all stops in gtfs" do
      stop_ids = [
        "WR-0329-02",
        "WR-0325-02",
        "WR-0264-02"
      ]

      assert :ok =
               ExportUpload.validate_stop_ids_in_gtfs(
                 stop_ids,
                 FakeRepo
               )
    end

    test "returns missing stop if some stops missing from GTFS" do
      stop_ids = [
        "morket-borket",
        "mcdongals",
        "sbubby",
        "WR-0329-02"
      ]

      assert {:error,
              {:stop_id_not_in_gtfs,
               {"Export has stops not present in GTFS",
                [stop_id_not_in_gtfs: ["morket-borket", "mcdongals", "sbubby"]]}}} =
               ExportUpload.validate_stop_ids_in_gtfs(
                 stop_ids,
                 FakeRepo
               )
    end
  end

  describe "validate_stop_order/3" do
    test "returns ok if stop time order is valid" do
      valid_stop_times = [
        %{
          arrival_time: "10:31:00",
          departure_time: "10:31:00",
          stop_id: "FS-0049-S",
          stop_sequence: "0",
          trip_id: "October26November2-781218-9733"
        },
        %{
          arrival_time: "10:45:00",
          departure_time: "10:45:00",
          stop_id: "NEC-2287",
          stop_sequence: "10",
          trip_id: "October26November2-781218-9733"
        },
        %{
          arrival_time: "11:01:00",
          departure_time: "11:01:00",
          stop_id: "NEC-2276-01",
          stop_sequence: "20",
          trip_id: "October26November2-781218-9733"
        }
      ]

      assert :ok = ExportUpload.validate_stop_order(valid_stop_times)
    end

    test "returns invalid stop time info if stop times ordering is invalid" do
      invalid_stop_times = [
        %{
          arrival_time: "10:31:00",
          departure_time: "10:31:00",
          stop_id: "FS-0049-S",
          stop_sequence: "0",
          trip_id: "October26November2-781218-9733"
        },
        %{
          arrival_time: "10:30:00",
          departure_time: "10:30:00",
          stop_id: "NEC-2287",
          stop_sequence: "10",
          trip_id: "October26November2-781218-9733"
        },
        %{
          arrival_time: "11:01:00",
          departure_time: "11:00:00",
          stop_id: "NEC-2276-01",
          stop_sequence: "20",
          trip_id: "October26November2-781218-9733"
        }
      ]

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
               ExportUpload.validate_stop_order(invalid_stop_times)
    end
  end

  describe "validate_one_of_north_south_stations/3" do
    test "returns ok if North but not South Station is served" do
      assert :ok =
               ExportUpload.validate_one_of_north_south_stations([
                 "BNT-0000",
                 "WR-0045-S"
               ])
    end

    test "returns ok if South but not North Station is served" do
      assert :ok =
               ExportUpload.validate_one_of_north_south_stations([
                 "MM-0023-S",
                 "NEC-2287"
               ])
    end

    test "returns error if North and South Stations are both served" do
      assert :both =
               ExportUpload.validate_one_of_north_south_stations([
                 "BNT-0000",
                 "WR-0045-S",
                 "MM-0023-S",
                 "NEC-2287"
               ])
    end

    test "returns error if neither North nor South Station is served" do
      assert :neither =
               ExportUpload.validate_one_of_north_south_stations([
                 "WR-0045-S",
                 "WR-0053-S"
               ])
    end
  end

  describe "validate_one_or_all_routes_from_one_side/3" do
    test "returns empty error route lists if all Northside routes have a trip" do
      assert {[], []} =
               ExportUpload.validate_one_or_all_routes_from_one_side([
                 %{
                   route_id: "CR-Newburyport",
                   service_id: "FALL 2025-SOUTHWKD-Weekday-11A",
                   trip_id: "Weekday-789267-102"
                 },
                 %{
                   route_id: "CR-Haverhill",
                   service_id: "FALL 2025-SOUTHWKD-Weekday-11A",
                   trip_id: "Weekday-789267-202"
                 },
                 %{
                   route_id: "CR-Lowell",
                   service_id: "FALL 2025-SOUTHWKD-Weekday-11A",
                   trip_id: "Weekday-789267-302"
                 },
                 %{
                   route_id: "CR-Fitchburg",
                   service_id: "FALL 2025-SOUTHWKD-Weekday-11A",
                   trip_id: "Weekday-789267-402"
                 }
               ])
    end

    test "returns empty error route lists if exactly one Northside route has a trip" do
      assert {[], []} =
               ExportUpload.validate_one_or_all_routes_from_one_side([
                 %{
                   route_id: "CR-Newburyport",
                   service_id: "FALL 2025-SOUTHWKD-Weekday-11A",
                   trip_id: "Weekday-789267-102"
                 },
                 %{
                   route_id: "CR-Newburyport",
                   service_id: "FALL 2025-SOUTHWKD-Weekday-11A",
                   trip_id: "Weekday-789267-104"
                 },
                 %{
                   route_id: "CR-Newburyport",
                   service_id: "FALL 2025-SOUTHWKD-Weekday-11A",
                   trip_id: "Weekday-789267-101"
                 },
                 %{
                   route_id: "CR-Newburyport",
                   service_id: "FALL 2025-SOUTHWKD-Weekday-11A",
                   trip_id: "Weekday-789267-103"
                 }
               ])
    end

    test "returns missing routes if more than one but not all Northside routes have a trip" do
      assert {["CR-Fitchburg", "CR-Lowell"], []} =
               ExportUpload.validate_one_or_all_routes_from_one_side([
                 %{
                   route_id: "CR-Newburyport",
                   service_id: "FALL 2025-SOUTHWKD-Weekday-11A",
                   trip_id: "Weekday-789267-102"
                 },
                 %{
                   route_id: "CR-Haverhill",
                   service_id: "FALL 2025-SOUTHWKD-Weekday-11A",
                   trip_id: "Weekday-789267-202"
                 }
               ])
    end

    test "returns empty error route lists for a single route not in either side's required list" do
      assert {[], []} =
               ExportUpload.validate_one_or_all_routes_from_one_side([
                 %{
                   route_id: "CR-Foxboro",
                   service_id: "FALL 2025-SOUTHWKD-Weekday-11A",
                   trip_id: "Weekday-789267-902"
                 },
                 %{
                   route_id: "CR-Foxboro",
                   trip_headsign: "Providence via Foxboro",
                   trip_id: "Weekday-789267-103"
                 }
               ])
    end

    test "returns invalid routes for multiple routes not in either side's required list" do
      assert {[], ["CR-Foxboro", "CR-Nowhere"]} =
               ExportUpload.validate_one_or_all_routes_from_one_side([
                 %{
                   route_id: "CR-Foxboro",
                   service_id: "FALL 2025-SOUTHWKD-Weekday-11A",
                   trip_id: "Weekday-789267-902"
                 },
                 %{
                   route_id: "CR-Nowhere",
                   service_id: "FALL 2025-SOUTHWKD-Weekday-11A",
                   trip_id: "Weekday-789267-999"
                 }
               ])
    end
  end

  describe "validate_transfers/3" do
    defmodule ImportWithTransfers do
      def stream_csv_rows(_, "stop_times.txt") do
      end

      def stream_csv_rows(_, "transfers.txt") do
      end
    end

    defmodule ImportMissingTransfers do
      def stream_csv_rows(_, "stop_times.txt") do
      end

      def stream_csv_rows(_, "transfers.txt"), do: []
    end

    test "returns ok if all appopriate trips have transfers" do
      assert :ok =
               ExportUpload.validate_transfers(
                 [
                   %{
                     from_stop_id: "ER-0183",
                     to_stop_id: "ER-0183",
                     from_trip_id: "1234",
                     to_trip_id: "5678",
                     transfer_type: "1"
                   }
                 ],
                 [
                   %{
                     arrival_time: "",
                     departure_time: "10:00:00",
                     stop_id: "BNT-0000",
                     stop_sequence: "10",
                     trip_id: "1234"
                   },
                   %{
                     arrival_time: "10:30:00",
                     departure_time: "",
                     stop_id: "ER-0183",
                     stop_sequence: "20",
                     trip_id: "1234"
                   },
                   %{
                     arrival_time: "",
                     departure_time: "10:35:00",
                     stop_id: "ER-0183",
                     stop_sequence: "10",
                     trip_id: "5678"
                   },
                   %{
                     arrival_time: "11:00:00",
                     departure_time: "",
                     stop_id: "ER-0362",
                     stop_sequence: "20",
                     trip_id: "5678"
                   }
                 ]
               )
    end

    test "returns an error if any transfers are missing" do
      expected_trips_with_missing_transfers = MapSet.new(["5678"])

      assert {:error, {:trips_missing_transfers, ^expected_trips_with_missing_transfers}} =
               ExportUpload.validate_transfers(
                 [],
                 [
                   %{
                     arrival_time: "",
                     departure_time: "10:00:00",
                     stop_id: "BNT-0000",
                     stop_sequence: "10",
                     trip_id: "1234"
                   },
                   %{
                     arrival_time: "10:30:00",
                     departure_time: "",
                     stop_id: "ER-0183",
                     stop_sequence: "20",
                     trip_id: "1234"
                   },
                   %{
                     arrival_time: "",
                     departure_time: "10:35:00",
                     stop_id: "ER-0183",
                     stop_sequence: "10",
                     trip_id: "5678"
                   },
                   %{
                     arrival_time: "11:00:00",
                     departure_time: "",
                     stop_id: "ER-0362",
                     stop_sequence: "20",
                     trip_id: "5678"
                   }
                 ]
               )
    end
  end

  describe "schedule_data_from_zip/3" do
    @tag export: "valid_export.zip"
    test "extracts schedule data", %{export: export} do
      zip_contents = File.read!("#{@export_dir}/#{export}")

      assert %{
               "SPRING2025-SOUTHSS-Weekend-66" => %{
                 "October26November2-781218-9733" => %{
                   direction_id: 0,
                   route_id: "CR-Foxboro",
                   stop_times: [
                     %{
                       arrival_time: "10:45:00",
                       departure_time: "10:45:00",
                       stop_id: "NEC-2287",
                       stop_sequence: 0
                     },
                     %{
                       arrival_time: "10:50:00",
                       departure_time: "10:50:00",
                       stop_id: "NEC-2276-01",
                       stop_sequence: 10
                     },
                     %{
                       arrival_time: "11:05:00",
                       departure_time: "11:05:00",
                       stop_id: "FB-0118-01",
                       stop_sequence: 20
                     },
                     %{
                       arrival_time: "11:50:00",
                       departure_time: "11:50:00",
                       stop_id: "FS-0049-S",
                       stop_sequence: 30
                     }
                   ],
                   short_name: "9733"
                 },
                 "October26November2-781219-9834" => %{
                   direction_id: 1,
                   route_id: "CR-Foxboro",
                   stop_times: [
                     %{
                       arrival_time: "10:15:00",
                       departure_time: "10:15:00",
                       stop_id: "NEC-1851-03",
                       stop_sequence: 0
                     },
                     %{
                       arrival_time: "10:22:00",
                       departure_time: "10:22:00",
                       stop_id: "NEC-1891-02",
                       stop_sequence: 10
                     },
                     %{
                       arrival_time: "10:35:00",
                       departure_time: "10:35:00",
                       stop_id: "NEC-1969-04",
                       stop_sequence: 20
                     },
                     %{
                       arrival_time: "10:45:00",
                       departure_time: "10:45:00",
                       stop_id: "NEC-2040-01",
                       stop_sequence: 30
                     },
                     %{
                       arrival_time: "11:30:00",
                       departure_time: "11:30:00",
                       stop_id: "FS-0049-S",
                       stop_sequence: 40
                     }
                   ],
                   short_name: "9834"
                 }
               }
             } == ExportUpload.schedule_data_from_zip(zip_contents)
    end
  end
end
