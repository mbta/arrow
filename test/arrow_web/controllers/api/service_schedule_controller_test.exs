defmodule ArrowWeb.API.ServiceScheduleControllerTest do
  use ArrowWeb.ConnCase, async: true

  import Arrow.Factory
  import Arrow.HastusFixtures

  describe "GET /api/service-schedules" do
    @tag :authenticated
    test "returns exports and their hastus services for active disruptions", %{conn: conn} do
      line = insert(:gtfs_line, id: "test-line-1", short_name: "TL1", long_name: "Test Line 1")

      inactive_disruption = insert(:disruption_v2, mode: :subway, is_active: false)

      _inactive_hastus_export =
        export_fixture(%{
          disruption_id: inactive_disruption.id,
          line_id: line.id,
          services: [
            %{
              name: "service-for-inactive-disruption",
              service_dates: [
                %{start_date: ~D[2025-03-31], end_date: ~D[2025-04-03]}
              ]
            }
          ]
        })

      out_of_range_disruption = insert(:disruption_v2, mode: :subway, is_active: true)

      _out_of_range_hastus_export =
        export_fixture(%{
          disruption_id: out_of_range_disruption.id,
          line_id: line.id,
          services: [
            %{
              name: "out-of-range-service",
              service_dates: [
                %{start_date: ~D[2025-04-30], end_date: ~D[2025-05-03]}
              ]
            }
          ]
        })

      disruption = insert(:disruption_v2, mode: :subway, is_active: true)

      hastus_export =
        export_fixture(%{
          disruption_id: disruption.id,
          line_id: line.id,
          services: [
            %{
              name: "test-service-1",
              service_dates: [
                %{start_date: ~D[2025-03-22], end_date: ~D[2025-03-23]},
                %{start_date: ~D[2025-03-29], end_date: ~D[2025-03-30]}
              ]
            }
          ]
        })

      [service] = hastus_export.services

      assert response =
               conn
               |> get(~p"/api/service-schedules?start_date=2025-03-26&end_date=2025-04-26")
               |> json_response(200)

      assert [data] = response

      assert <<"https://s3.amazonaws.com/", _::binary>> = download_url = data["download_url"]

      assert %{
               "hastus_export_id" => hastus_export.id,
               "disruption_id" => disruption.id,
               "disruption_title" => disruption.title,
               "line_id" => hastus_export.line_id,
               "services" => [
                 %{
                   "service_id" => service.id,
                   "service_name" => "test-service-1",
                   "date_ranges" => [
                     %{"start_date" => "2025-03-29", "end_date" => "2025-03-30"}
                   ]
                 }
               ],
               "trip_route_directions" => [],
               "download_url" => download_url
             } == data
    end

    @tag :authenticated
    test "requires valid start_date and end_date parameters", %{conn: conn} do
      assert conn
             |> get(~p"/api/service-schedules?start_date=2025-13-01&end_date=2025-04-26")
             |> json_response(400) == %{"error" => "`start_date` is not a valid date"}

      assert conn
             |> get(~p"/api/service-schedules?start_date=2025-01-01&end_date=oops")
             |> json_response(400) == %{"error" => "`end_date` is not a valid date"}

      assert conn
             |> get(~p"/api/service-schedules?start_date=2025-02-01&end_date=2025-01-01")
             |> json_response(409) == %{"error" => "`end_date` must be after `start_date`"}
    end
  end
end
