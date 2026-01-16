defmodule ArrowWeb.CommuterRailTimetableController do
  use ArrowWeb, :controller

  alias Arrow.Trainsformer
  alias Arrow.Trainsformer.ExportUpload

  def show(conn, %{"trainsformer_export_id" => export_id} = params) do
    trainsformer_export = Trainsformer.get_export!(export_id)

    {:ok, zip_binary} = ExportUpload.download_from_s3(trainsformer_export.s3_path)

    schedule_data = ExportUpload.schedule_data_from_zip(zip_binary)

    # Get service, defaulting to first one available
    available_services = schedule_data |> Map.keys() |> Enum.sort()

    service_id = Map.get(params, "service_id", Enum.at(available_services, 0))

    # Get route, defaulting to first one available
    available_routes =
      schedule_data
      |> Map.get(service_id)
      |> Enum.map(fn {_trip_id, trip} -> trip.route_id end)
      |> Enum.uniq_by(& &1)
      |> Enum.sort()

    route_id = Map.get(params, "route_id", Enum.at(available_routes, 0))

    direction_id =
      case Map.get(params, "direction_id") do
        "0" -> 0
        "1" -> 1
        nil -> 0
      end

    # Take schedule data for all trains, combine to get stop ordering
    _all_schedules =
      schedule_data
      |> Map.get(service_id)
      |> Enum.map(fn {_trip_id, trip_data} -> trip_data end)
      |> Enum.filter(fn trip_data ->
        trip_data.route_id == route_id and trip_data.direction_id == direction_id
      end)

    # Sort trips by relevant times

    # Render
    render(conn, :show,
      service_id: service_id,
      route_id: route_id,
      available_routes: available_routes
    )
  end
end
