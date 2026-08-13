defmodule ArrowWeb.API.DisruptionV2ControllerTest do
  use ArrowWeb.ConnCase

  import Arrow.{LimitsFixtures, ShuttlesFixtures, Factory}

  describe "index/2" do
    @tag :authenticated
    test "gives 404 for non-existing disruption", %{conn: conn} do
      assert_error_sent 404, fn -> get(conn, "/api/disruption/100") end
    end

    @tag :authenticated
    test "includes all data", %{conn: conn} do
      shuttle = shuttle_fixture(%{}, true, true)
      replacement_service = insert(:replacement_service, %{shuttle: shuttle})
      disruption = replacement_service.disruption
      limit_fixture(disruption_id: disruption.id)
      Arrow.HastusFixtures.export_fixture(disruption_id: disruption.id)
      Arrow.TrainsformerFixtures.export_fixture(disruption_id: disruption.id)

      shuttle_name = shuttle.shuttle_name

      res =
        conn
        |> get(~p"/api/disruption/#{disruption.id}")
        |> json_response(200)

      assert %{
               "id" => _,
               "hastus_exports" => [
                 %{
                   "id" => _,
                   "line_id" => _,
                   "s3_path" => _,
                   "services" => _
                 }
               ],
               "trainsformer_exports" => [
                 %{
                   "id" => _,
                   "routes" => _,
                   "s3_path" => _,
                   "services" => _
                 }
               ],
               "replacement_services" => [
                 %{
                   "start_date" => _,
                   "end_date" => _,
                   "reason" => _,
                   "shuttle_name" => ^shuttle_name,
                   "timetable" => %{
                     "weekday" => %{"0" => [[_ | _] | _], "1" => [[_ | _] | _]},
                     "friday" => nil,
                     "saturday" => %{"0" => [[_ | _] | _], "1" => [[_ | _] | _]},
                     "sunday" => nil
                   }
                 }
               ],
               "limits" => [
                 %{
                   "start_date" => _,
                   "end_date" => _,
                   "start_stop" => _,
                   "end_stop" => _,
                   "route_id" => _,
                   "days" => %{}
                 }
               ]
             } = res
    end
  end
end
