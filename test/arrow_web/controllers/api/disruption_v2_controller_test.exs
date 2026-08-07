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

      replacement_service =
        insert(:replacement_service, %{
          shuttle: shuttle
        })

      disruption = replacement_service.disruption
      limit = limit_fixture(disruption_id: disruption.id)

      %{s3_path: hastus_export_url} =
        Arrow.HastusFixtures.export_fixture(disruption_id: disruption.id)

      %{s3_path: trainsformer_export_url} =
        Arrow.TrainsformerFixtures.export_fixture(disruption_id: disruption.id)

      disruption_id = to_string(disruption.id)
      replacement_service_id = to_string(replacement_service.id)
      limit_id = to_string(limit.id)
      shuttle_id = to_string(shuttle.id)

      routes = shuttle.routes |> Map.new(&{to_string(&1.id), &1})

      stops =
        shuttle.routes
        |> Enum.flat_map(& &1.route_stops)
        |> Map.new(&{to_string(&1.gtfs_stop_id), &1.gtfs_stop})

      res =
        conn
        |> get(~p"/api/disruption/#{disruption.id}")
        |> json_response(200)

      assert %{
               "data" => %{
                 "type" => "disruption_v2",
                 "id" => ^disruption_id,
                 "attributes" => %{
                   "hastus_exports" => [^hastus_export_url],
                   "trainsformer_exports" => [^trainsformer_export_url]
                 },
                 "relationships" => %{
                   "replacement_services" => %{
                     "data" => [%{"id" => ^replacement_service_id}]
                   },
                   "limits" => %{
                     "data" => [%{"id" => ^limit_id}]
                   },
                   "shuttles" => %{
                     "data" => [%{"id" => ^shuttle_id}]
                   }
                 }
               },
               "included" => included,
               "jsonapi" => _
             } = res

      Enum.each(
        included,
        fn
          %{"type" => "replacement_service", "id" => ^replacement_service_id} ->
            nil

          %{
            "type" => "limit",
            "id" => ^limit_id,
            "attributes" => %{
              "days" => days,
              "start_date" => start_date,
              "start_stop" => start_stop,
              "end_date" => end_date,
              "end_stop" => end_stop
            }
          } ->
            assert ^start_date = to_string(limit.start_date)
            assert ^end_date = to_string(limit.end_date)
            assert ^start_stop = to_string(limit.start_stop_id)
            assert ^end_stop = to_string(limit.end_stop_id)

            assert ^days =
                     limit.limit_day_of_weeks
                     |> Map.new(
                       &{to_string(&1.day_name),
                        %{
                          "start_time" => &1.start_time,
                          "end_time" => &1.end_time,
                          "is_all_day" => &1.all_day? == true
                        }}
                     )

          %{"type" => "shuttle", "id" => ^shuttle_id} ->
            nil

          %{
            "type" => "shuttle_route",
            "id" => id,
            "attributes" => attributes
          } ->
            route = routes[id]
            assert to_string(route.destination) == attributes["destination"]
            assert to_string(route.direction_id) == attributes["direction_id"]
            # Will always be disabled in test because we don't actually upload shape files
            assert "disabled" == attributes["shape_id"]

          %{
            "type" => "shuttle_route_stop",
            "relationships" => %{
              "gtfs_stop" => %{"data" => %{"id" => gtfs_stop_id}}
            },
            "attributes" => %{"time_to_next_stop" => _}
          } ->
            assert Map.has_key?(stops, gtfs_stop_id)

          %{
            "type" => "gtfs_stop",
            "id" => id,
            "attributes" => %{
              "lat" => lat,
              "lon" => lon,
              "name" => name
            }
          } ->
            assert %{lat: ^lat, lon: ^lon, name: ^name} = stops[id]
        end
      )
    end
  end
end
