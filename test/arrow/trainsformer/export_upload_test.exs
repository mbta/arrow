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
end
