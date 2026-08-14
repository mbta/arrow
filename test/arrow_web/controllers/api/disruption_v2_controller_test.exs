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
                   "services" => [
                     %{
                       "id" => _,
                       "name" => _,
                       "service_dates" => [
                         %{"start_date" => _, "end_date" => _} | _
                       ]
                     }
                     | _
                   ]
                 }
               ],
               "trainsformer_exports" => [
                 %{
                   "id" => _,
                   "routes" => _,
                   "s3_path" => _,
                   "services" => [
                     %{
                       "id" => _,
                       "name" => _,
                       "service_dates" => [
                         %{"start_date" => _, "end_date" => _, "days_of_week" => [_ | _]} | _
                       ]
                     }
                     | _
                   ]
                 }
               ],
               "replacement_services" => [
                 %{
                   "start_date" => _,
                   "end_date" => _,
                   "reason" => _,
                   "shuttle_name" => ^shuttle_name,
                   "timetable" => timetables
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

      active_timetables =
        for {_day, %{"0" => [_ | _] = d0_timetable, "1" => [_ | _] = d1_timetable}} <- timetables,
            trip <- d0_timetable ++ d1_timetable,
            %{"stop_id" => stop_id, "stop_time" => _} <- trip do
          assert not is_nil(stop_id)
        end

      assert [_ | _] = active_timetables
    end
  end
end
