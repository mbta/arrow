defmodule Arrow.Trainsformer.ExportUploadTest do
  use Arrow.DataCase, async: true

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
  end
end
