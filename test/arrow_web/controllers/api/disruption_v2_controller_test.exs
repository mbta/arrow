defmodule ArrowWeb.API.DisruptionV2ControllerTest do
  use ArrowWeb.ConnCase

  import Arrow.{DisruptionsFixtures, LimitsFixtures, ShuttlesFixtures, Factory}

  describe "index/2" do
    # @tag :authenticated
    # test "non-admin user can access the disruption API", %{conn: conn} do
    #   assert %{status: 200} = get(conn, "/api/disruption/1")
    # end

    @tag :authenticated
    test "gives 404 for non-existing disruption", %{conn: conn} do
      assert_error_sent 404, fn -> get(conn, "/api/disruption/100") end
    end

    @tag :authenticated
    test "includes all data", %{conn: conn} do
      shuttle = shuttle_fixture(%{}, true, true)

      replacement_service =
        insert(:replacement_service, %{
          shuttle: shuttle
        })

      disruption = replacement_service.disruption
      limit = limit_fixture(disruption_id: disruption.id)
      day_of_week = limit_day_of_week_fixture(limit_id: limit.id)
      hastus_export = Arrow.HastusFixtures.export_fixture(disruption_id: disruption.id)
      trainsformer_export = Arrow.HastusFixtures.export_fixture(disruption_id: disruption.id)

      res =
        conn
        |> get(~p"/api/disruption/#{disruption.id}")
        |> json_response(200)

      assert %{
               "data" => %{
                 "type" => "disruption_v2",
                 "attributes" => attributes,
                 "relationships" => %{
                   "replacement_services" => %{
                     "data" => [replacement_service_id]
                   },
                   "limits" => %{
                     "data" => [limit_id]
                   },
                   "shuttles" => %{
                     "data" => [shuttle_id]
                   }
                 }
               },
               "included" => included,
               "jsonapi" => _
             } = res
    end
  end
end
