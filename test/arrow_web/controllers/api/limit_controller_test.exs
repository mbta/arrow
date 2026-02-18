defmodule ArrowWeb.API.LimitControllerTest do
  use ArrowWeb.ConnCase

  import Arrow.Factory

  describe "index/2" do
    @tag :authenticated
    test "returns limits within date range", %{conn: conn} do
      disruption = insert(:disruption_v2, %{status: :approved, title: "Test Disruption"})
      route = insert(:gtfs_route)
      start_stop = insert(:gtfs_stop)
      end_stop = insert(:gtfs_stop)

      limit =
        insert(:limit, %{
          disruption: disruption,
          route: route,
          start_stop: start_stop,
          end_stop: end_stop,
          start_date: ~D[2025-06-01],
          end_date: ~D[2025-06-30]
        })

      insert(:limit_day_of_week, %{
        limit: limit,
        day_name: :monday,
        active?: true,
        start_time: "09:00",
        end_time: "17:00"
      })

      insert(:limit_day_of_week, %{
        limit: limit,
        day_name: :tuesday,
        active?: true,
        start_time: nil,
        end_time: nil
      })

      # inactive day of week (should not appear in response)
      insert(:limit_day_of_week, %{
        limit: limit,
        day_name: :wednesday,
        active?: false
      })

      response =
        conn
        |> get("/api/limits?start_date=2025-06-01&end_date=2025-06-30")
        |> json_response(200)

      assert %{"data" => [limit_data], "jsonapi" => %{"version" => "1.0"}} = response

      assert %{"id" => _id, "type" => "limit", "attributes" => attributes} = limit_data

      assert attributes["disruption_id"] == disruption.id
      assert attributes["disruption_name"] == "Test Disruption"
      assert attributes["route_id"] == route.id
      assert attributes["start_stop"] == start_stop.id
      assert attributes["end_stop"] == end_stop.id
      assert attributes["start_date"] == "2025-06-01"
      assert attributes["end_date"] == "2025-06-30"

      assert attributes["days"] == %{
               "monday" => %{
                 "start_time" => "09:00",
                 "end_time" => "17:00",
                 "is_all_day" => false
               },
               "tuesday" => %{
                 "start_time" => nil,
                 "end_time" => nil,
                 "is_all_day" => true
               }
             }

      refute Map.has_key?(attributes["days"], "wednesday")
    end

    @tag :authenticated
    test "returns empty array when no limits exist in date range", %{conn: conn} do
      conn = get(conn, "/api/limits?start_date=2025-01-01&end_date=2025-01-31")

      assert %{
               "data" => [],
               "jsonapi" => %{"version" => "1.0"}
             } = json_response(conn, 200)
    end

    @tag :authenticated
    test "does not return limits outside date range", %{conn: conn} do
      disruption = insert(:disruption_v2, %{status: :approved})
      route = insert(:gtfs_route)
      start_stop = insert(:gtfs_stop)
      end_stop = insert(:gtfs_stop)

      # Limit that ends before the range starts
      insert(:limit, %{
        disruption: disruption,
        route: route,
        start_stop: start_stop,
        end_stop: end_stop,
        start_date: ~D[2025-01-01],
        end_date: ~D[2025-01-31]
      })

      # Limit that starts after the range ends
      insert(:limit, %{
        disruption: disruption,
        route: route,
        start_stop: start_stop,
        end_stop: end_stop,
        start_date: ~D[2025-08-01],
        end_date: ~D[2025-08-31]
      })

      conn = get(conn, "/api/limits?start_date=2025-06-01&end_date=2025-06-30")

      assert %{
               "data" => [],
               "jsonapi" => %{"version" => "1.0"}
             } = json_response(conn, 200)
    end

    @tag :authenticated
    test "returns 400 for invalid date format", %{conn: conn} do
      conn = get(conn, "/api/limits?start_date=invalid&end_date=2025-06-30")

      assert %{"error" => "Invalid date format. Use YYYY-MM-DD"} = json_response(conn, 400)
    end

    @tag :authenticated
    test "returns 400 when end date is before start date", %{conn: conn} do
      conn = get(conn, "/api/limits?start_date=2025-06-30&end_date=2025-06-01")

      assert %{"error" => "End date must be after start date"} = json_response(conn, 400)
    end

    @tag :authenticated
    test "filters out inactive disruptions", %{conn: conn} do
      inactive_disruption = insert(:disruption_v2, %{status: :pending})
      route = insert(:gtfs_route)
      start_stop = insert(:gtfs_stop)
      end_stop = insert(:gtfs_stop)

      insert(:limit, %{
        disruption: inactive_disruption,
        route: route,
        start_stop: start_stop,
        end_stop: end_stop,
        start_date: ~D[2025-06-01],
        end_date: ~D[2025-06-30]
      })

      conn = get(conn, "/api/limits?start_date=2025-06-01&end_date=2025-06-30")

      assert %{
               "data" => [],
               "jsonapi" => %{"version" => "1.0"}
             } = json_response(conn, 200)
    end

    @tag :authenticated
    test "returns limits that overlap with date range", %{conn: conn} do
      disruption = insert(:disruption_v2, %{status: :approved})
      route = insert(:gtfs_route)
      start_stop = insert(:gtfs_stop)
      end_stop = insert(:gtfs_stop)
      end_stop_2 = insert(:gtfs_stop)

      # Limit that starts before and ends during range
      insert(:limit, %{
        disruption: disruption,
        route: route,
        start_stop: start_stop,
        end_stop: end_stop,
        start_date: ~D[2025-05-15],
        end_date: ~D[2025-06-15]
      })

      # Limit that starts during and ends after range
      insert(:limit, %{
        disruption: disruption,
        route: route,
        start_stop: start_stop,
        end_stop: end_stop_2,
        start_date: ~D[2025-06-15],
        end_date: ~D[2025-07-15]
      })

      conn = get(conn, "/api/limits?start_date=2025-06-01&end_date=2025-06-30")

      assert %{
               "data" => data,
               "jsonapi" => %{"version" => "1.0"}
             } = json_response(conn, 200)

      assert length(data) == 2
    end
  end
end
