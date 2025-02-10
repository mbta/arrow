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
        replacement_service_factory(%{
          start_date: ~D[2024-01-01],
          end_date: ~D[2024-01-02]
        })

      active_start = ~D[2025-01-01]
      active_end = ~D[2025-01-02]
      expected_reason = "active today"

      _active_replacement =
        replacement_service_factory(%{
          reason: expected_reason,
          start_date: active_start,
          end_date: active_end,
          shuttle: shuttle
        })
        |> insert()

      active_start_date_formatted = Date.to_iso8601(active_start)
      active_end_date_formatted = Date.to_iso8601(active_end)

      res =
        get(
          conn,
          "/api/replacement-service?start_date=#{active_end_date_formatted}&end_date=#{active_end_date_formatted}"
        )
        |> json_response(200)

      assert %{
               "data" => [
                 %{
                   "attributes" => %{
                     "reason" => ^expected_reason,
                     "start_date" => ^active_start_date_formatted,
                     "end_date" => ^active_end_date_formatted,
                     "timetable" => %{"saturday" => _saturday, "sunday" => _sunday}
                   }
                 }
               ],
               "included" => included_list,
               "jsonapi" => _
             } = res

      refute Enum.empty?(included_list)

      assert Enum.any?(included_list, &match?(%{"type" => "disruption_v2"}, &1))
      assert Enum.any?(included_list, &match?(%{"type" => "shuttle"}, &1))
      assert Enum.any?(included_list, &match?(%{"type" => "shuttle_route"}, &1))
      assert Enum.any?(included_list, &match?(%{"type" => "shuttle_route_stop"}, &1))
    end
  end
end
