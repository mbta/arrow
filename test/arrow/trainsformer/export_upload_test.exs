defmodule Arrow.Trainsformer.ExportUploadTest do
  use Arrow.DataCase, async: true
  import Test.Support.Helpers

  alias Arrow.Trainsformer.ExportUpload

  @export_dir "test/support/fixtures/trainsformer"

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
        %Unzip.Entry{file_name: "stop_times.txt"}
      end
    end

    defmodule FakeRepo do
      def get(_, "WR-0329-02"), do: %Arrow.Gtfs.Stop{}
      def get(_, "WR-0325-02"), do: %Arrow.Gtfs.Stop{}
      def get(_, "WR-0264-02"), do: %Arrow.Gtfs.Stop{}
      def get(_, _), do: nil
    end

    test "returns ok if all stops in gtfs" do
      defmodule ImportRealStops do
        def stream_csv_rows(_) do
          rows = [
            "Base-772221-5208,05:35:00,05:35:00,WR-0329-02,00,North Station via Reading,0,1,1,,0",
            "Base-772221-5208,05:37:00,05:37:00,WR-0325-02,10,North Station via Reading,0,0,1,,0",
            "Base-772221-5208,05:44:00,05:44:00,WR-0264-02,20,North Station via Reading,0,0,1,,0"
          ]

          Stream.map(rows, & &1)
        end
      end

      assert :ok = ExportUpload.validate_stop_times_in_gtfs(%Unzip{}, FakeUnzip, ImportRealStops)
    end

    test "returns missing stop times if some stops missing from GTFS" do
      defmodule ImportFakeStops do
        def stream_csv_rows(_) do
          rows = [
            "Base-772221-5208,05:35:00,05:35:00,morket-borket,00,North Station via Reading,0,1,1,,0",
            "Base-772221-5208,05:37:00,05:37:00,sbubby,North Station via Reading,0,0,1,,0",
            "Base-772221-5208,05:44:00,05:44:00,mcdongals,20,North Station via Reading,0,0,1,,0"
          ]

          Stream.map(rows, & &1)
        end
      end

      assert {:invalid_export_stops, "morket-borket", "sbubby", "mcdongals"} =
               ExportUpload.validate_stop_times_in_gtfs(%Unzip{}, FakeUnzip, ImportRealStops)
    end
  end
end
