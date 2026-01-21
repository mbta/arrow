defmodule ArrowWeb.CommuterRailTimetableControllerTest do
  use ArrowWeb.ConnCase

  import Arrow.Factory
  import Test.Support.Helpers

  describe "show/2" do
    @tag :authenticated_admin
    test "shows basic information", %{conn: conn} do
      reassign_env(
        :trainsformer_export_storage_request_fn,
        {ArrowWeb.CommuterRailTimetableControllerTest.FakeRequestWithValidExport, :request}
      )

      reassign_env(:trainsformer_export_storage_enabled?, true)

      insert(:gtfs_stop, %{id: "NEC-2287", name: "South Station"})
      insert(:gtfs_stop, %{id: "NEC-2276-01", name: "Back Bay"})
      insert(:gtfs_stop, %{id: "FB-0118-01", name: "Dedham Corporate Center"})
      insert(:gtfs_stop, %{id: "FS-0049-S", name: "Foxboro"})

      disruption = Arrow.DisruptionsFixtures.disruption_v2_fixture(%{mode: "commuter_rail"})

      export =
        Arrow.TrainsformerFixtures.export_fixture(%{
          disruption_id: disruption.id,
          services: [
            %{
              name: "SPRING2025-SOUTHSS-Weekend-66",
              service_dates: [
                %{start_date: ~D[2026-01-26], end_date: ~D[2026-01-26]}
              ]
            }
          ]
        })

      conn = get(conn, ~p"/trainsformer_exports/#{export.id}/timetable")

      response = html_response(conn, 200)

      assert response =~ disruption.title
      assert response =~ "/disruptions/#{disruption.id}"
      assert response =~ "01/26/2026"
      assert response =~ "SPRING2025-SOUTHSS-Weekend-66"
      assert response =~ "CR-Foxboro"
      assert response =~ "Back Bay"
      assert response =~ "10:50:00"
    end
  end

  defmodule FakeRequestWithValidExport do
    @export_dir "test/support/fixtures/trainsformer"

    def request(_) do
      {:ok, %{body: File.read!("#{@export_dir}/valid_export.zip")}}
    end
  end
end
