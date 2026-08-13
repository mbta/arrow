defmodule ArrowWeb.API.DisruptionV2Controller do
  use ArrowWeb, :controller
  import Ecto.Query, only: [from: 2]

  alias Arrow.Disruptions.{DisruptionV2, ReplacementService, Limit}
  alias Arrow.Shuttles.{Shuttle, Route, RouteStop}
  alias Arrow.{Hastus, Trainsformer}
  alias Plug.Conn

  @spec index(Conn.t(), map()) :: Conn.t()
  def index(conn, %{"id" => id}) do
    data =
      from(d in DisruptionV2,
        where: d.id == ^id,
        preload: [
          hastus_exports: [
            :trip_route_directions,
            services: [:service_dates]
          ],
          trainsformer_exports: [
            :routes,
            services: [service_dates: [:service_date_days_of_week]]
          ],
          limits: [:limit_day_of_weeks],
          replacement_services: [
            shuttle: [routes: [:shape, :route_stops]]
          ]
        ]
      )
      |> Arrow.Repo.one!()
      |> update_in([Access.key(:replacement_services), Access.all()], &replacement_service_data/1)
      |> update_in([Access.key(:hastus_exports), Access.all()], &hastus_export_data/1)
      |> update_in([Access.key(:trainsformer_exports), Access.all()], &trainsformer_export_data/1)
      |> update_in([Access.key(:limits), Access.all()], &limit_data/1)
      |> Map.take([
        :id,
        :title,
        :mode,
        :status,
        :description,
        :replacement_services,
        :hastus_exports,
        :trainsformer_exports,
        :limits
      ])

    json(conn, data)
  end

  defp replacement_service_data(%ReplacementService{} = replacement_service) do
    replacement_service
    |> ReplacementService.add_timetable()
    |> Map.update!(:shuttle, &shuttle_data/1)
    |> Map.take([:reason, :start_date, :end_date, :timetable, :shuttle])
  end

  defp shuttle_data(%Shuttle{} = shuttle) do
    shuttle
    |> update_in([Access.key(:routes), Access.all()], &shuttle_route_data/1)
    |> Map.take([:shuttle_name, :suffix, :routes, :disrupted_route_id, :routes])
  end

  defp shuttle_route_data(%Route{} = route) do
    route
    |> update_in([Access.key(:route_stops), Access.all()], &route_stop_data/1)
    |> Map.take([
      :destination,
      :direction_id,
      :direction_desc,
      :waypoint,
      :route_stops
    ])
    |> Map.merge(%{
      shape_id: route.shape.name,
      shape_uri: Arrow.Shuttles.Route.get_shape_uri(route.shape)
    })
  end

  defp route_stop_data(%RouteStop{} = route_stop) do
    route_stop
    |> Map.take([:direction_id, :stop_sequence, :time_to_next_stop])
    |> Map.put(:stop_id, route_stop.gtfs_stop_id || route_stop.stop_id)
  end

  defp hastus_export_data(%Hastus.Export{} = export) do
    export
    |> update_in([Access.key(:services), Access.all()], &hastus_service_data/1)
    |> update_in(
      [Access.key(:trip_route_directions), Access.all()],
      &Map.take(&1, [:hastus_route_id, :via_variant, :avi_code, :route_id])
    )
    |> Map.take([:id, :line_id, :services, :trip_route_directions, :s3_path])
  end

  defp hastus_service_data(%Hastus.Service{} = service) do
    service
    |> update_in(
      [Access.key(:service_dates), Access.all()],
      &Map.take(&1, [:start_date, :end_date])
    )
    |> Map.take([:id, :name, :service_dates])
  end

  defp trainsformer_export_data(%Trainsformer.Export{} = export) do
    export
    |> update_in([Access.key(:services), Access.all()], &trainsformer_service_data/1)
    |> update_in([Access.key(:routes), Access.all()], & &1.route_id)
    |> Map.take([:id, :services, :routes, :s3_path])
  end

  defp trainsformer_service_data(%Trainsformer.Service{} = service) do
    service
    |> update_in(
      [Access.key(:service_dates), Access.all()],
      &Map.take(&1, [:start_date, :end_date, :service_date_days_of_week])
    )
    |> Map.take([:id, :name, :service_dates])
  end

  defp limit_data(%Limit{} = limit) do
    limit
    |> Map.take([
      :route_id,
      :start_date,
      :end_date
    ])
    |> Map.merge(%{
      days:
        limit.limit_day_of_weeks
        |> Enum.filter(& &1.active?)
        |> Map.new(fn dow ->
          {dow.day_name,
           %{
             start_time: dow.start_time,
             end_time: dow.end_time,
             is_all_day: is_nil(dow.start_time) and is_nil(dow.end_time)
           }}
        end),
      start_stop: limit.start_stop_id,
      end_stop: limit.end_stop_id
    })
  end
end
