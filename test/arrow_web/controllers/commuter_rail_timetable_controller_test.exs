defmodule ArrowWeb.CommuterRailTimetableControllerTest do
  use ArrowWeb.ConnCase

  import Test.Support.Helpers

  describe "show/2" do
    @tag :authenticated_admin
    test "shows basic header with service and route information", %{conn: conn} do
      reassign_env(
        :trainsformer_export_storage_request_fn,
        {ArrowWeb.CommuterRailTimetableControllerTest.FakeRequestWithValidExport, :request}
      )

      reassign_env(:trainsformer_export_storage_enabled?, true)

      export = Arrow.TrainsformerFixtures.export_fixture()

      conn = get(conn, ~p"/trainsformer_exports/#{export.id}/timetable")

      response = html_response(conn, 200)

      assert response =~ "CR-Foxboro"
    end
  end

  defmodule FakeRequestWithValidExport do
    @export_dir "test/support/fixtures/trainsformer"

    def request(_) do
      {:ok, %{body: File.read!("#{@export_dir}/valid_export.zip")}}
    end
  end
end
