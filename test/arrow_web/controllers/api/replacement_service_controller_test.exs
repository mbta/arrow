defmodule ArrowWeb.API.ReplacementServiceControllerTest do
  use ArrowWeb.ConnCase

  import Arrow.Factory
  import Arrow.ShuttlesFixtures

  describe "index/2" do
    @tag :authenticated
    test "can be accessed by non-admin user", %{conn: conn} do
      assert %{status: 200} =
               get(conn, "/api/replacement-service", %{
                 start_date: Date.to_iso8601(~D[2025-01-01]),
                 end_date: Date.to_iso8601(~D[2025-01-02])
               })
    end

    @tag :authenticated
    test "gives 400 for invalid date range", %{conn: conn} do
      assert %{status: 400} =
               get(conn, "/api/replacement-service", %{
                 start_date: Date.to_iso8601(~D[2025-01-01]),
                 end_date: Date.to_iso8601(~D[2024-12-31])
               })
    end

    @tag :authenticated
    test "only shows active replacement services", %{conn: conn} do
      shuttle = shuttle_fixture(%{}, true, true)

      _inactive_replacement =
        insert(:replacement_service, %{
          start_date: ~D[2024-01-01],
          end_date: ~D[2024-01-02],
          shuttle: shuttle
        })

      active_start = ~D[2025-01-01]
      active_end = ~D[2025-01-02]
      expected_reason = "active today"

      _active_replacement =
        insert(:replacement_service, %{
          reason: expected_reason,
          start_date: active_start,
          end_date: active_end,
          shuttle: shuttle
        })

      active_start_date_formatted = Date.to_iso8601(active_start)
      active_end_date_formatted = Date.to_iso8601(active_end)

      res =
        conn
        |> get("/api/replacement-service?start_date=#{active_end_date_formatted}&end_date=#{active_end_date_formatted}")
        |> json_response(200)

      assert %{
               "data" => [
                 %{
                   "attributes" => %{
                     "reason" => ^expected_reason,
                     "start_date" => ^active_start_date_formatted,
                     "end_date" => ^active_end_date_formatted,
                     "timetable" => %{
                       "saturday" => %{"0" => _, "1" => _},
                       "sunday" => nil,
                       "weekday" => %{
                         "0" => [
                           [
                             %{
                               "stop_id" => shuttle_route_stop_id,
                               "stop_time" => shuttle_stop_time
                             }
                             | _
                           ]
                           | _
                         ],
                         "1" => _
                       }
                     }
                   }
                 }
               ],
               "jsonapi" => _
             } = res

      assert is_binary(shuttle_route_stop_id) and String.length(shuttle_route_stop_id) > 0
      assert is_binary(shuttle_stop_time) and String.length(shuttle_stop_time) > 0
    end
  end
end
