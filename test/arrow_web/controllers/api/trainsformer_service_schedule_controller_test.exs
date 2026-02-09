defmodule ArrowWeb.API.TrainsformerServiceScheduleControllerTest do
  use ArrowWeb.ConnCase, async: true

  import Arrow.Factory
  import Arrow.TrainsformerFixtures

  describe "GET /api/trainsformer-trainsformer-service-schedules" do
    @tag :authenticated
    test "returns exports and their trainsformer services for active disruptions", %{conn: conn} do
      inactive_disruption = insert(:disruption_v2, mode: :commuter_rail, status: :pending)

      _inactive_trainsformer_export =
        export_fixture(%{
          disruption_id: inactive_disruption.id,
          services: [
            %{
              name: "service-for-inactive-disruption",
              service_dates: [
                %{start_date: ~D[2025-03-31], end_date: ~D[2025-04-03]}
              ]
            }
          ]
        })

      out_of_range_disruption = insert(:disruption_v2, mode: :commuter_rail, status: :approved)

      _out_of_range_trainsformer_export =
        export_fixture(%{
          disruption_id: out_of_range_disruption.id,
          services: [
            %{
              name: "out-of-range-service",
              service_dates: [
                %{start_date: ~D[2025-04-30], end_date: ~D[2025-05-03]}
              ]
            }
          ]
        })

      disruption = insert(:disruption_v2, mode: :commuter_rail, status: :approved)

      trainsformer_export =
        export_fixture(%{
          disruption_id: disruption.id,
          services: [
            %{
              name: "test-service-1",
              service_dates: [
                %{start_date: ~D[2025-03-22], end_date: ~D[2025-03-23]},
                %{start_date: ~D[2025-03-29], end_date: ~D[2025-03-30]}
              ]
            }
          ],
          routes: [%{route_id: "CR-Worcester"}]
        })

      [service] = trainsformer_export.services
      [route] = trainsformer_export.routes

      assert response =
               conn
               |> get(
                 ~p"/api/trainsformer-service-schedules?start_date=2025-03-26&end_date=2025-04-26"
               )
               |> json_response(200)

      assert [data] = response

      assert <<"https://s3.amazonaws.com/", _::binary>> = download_url = data["download_url"]

      assert %{
               "trainsformer_export_id" => trainsformer_export.id,
               "disruption_id" => disruption.id,
               "disruption_title" => disruption.title,
               "services" => [
                 %{
                   "service_id" => service.id,
                   "service_name" => "test-service-1",
                   "date_ranges" => [
                     %{"start_date" => "2025-03-29", "end_date" => "2025-03-30"}
                   ]
                 }
               ],
               "routes" => [%{"id" => route.id, "route_name" => "CR-Worcester"}],
               "download_url" => download_url
             } == data
    end

    @tag :authenticated
    test "requires valid start_date and end_date parameters", %{conn: conn} do
      assert conn
             |> get(
               ~p"/api/trainsformer-service-schedules?start_date=2025-13-01&end_date=2025-04-26"
             )
             |> json_response(400) == %{"error" => "`start_date` is not a valid date"}

      assert conn
             |> get(~p"/api/trainsformer-service-schedules?start_date=2025-01-01&end_date=oops")
             |> json_response(400) == %{"error" => "`end_date` is not a valid date"}

      assert conn
             |> get(
               ~p"/api/trainsformer-service-schedules?start_date=2025-02-01&end_date=2025-01-01"
             )
             |> json_response(409) == %{"error" => "`end_date` must be after `start_date`"}
    end
  end
end
