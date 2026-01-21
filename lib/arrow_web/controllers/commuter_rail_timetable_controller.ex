defmodule ArrowWeb.CommuterRailTimetableController do
  use ArrowWeb, :controller

  alias Arrow.Gtfs.Stop
  alias Arrow.Repo
  alias Arrow.Trainsformer
  alias Arrow.Trainsformer.ExportUpload

  def show(conn, %{"trainsformer_export_id" => export_id} = params) do
    trainsformer_export = Trainsformer.get_export!(export_id)

    {:ok, zip_binary} = ExportUpload.download_from_s3(trainsformer_export.s3_path)

    schedule_data = ExportUpload.schedule_data_from_zip(zip_binary)

    # Get service, defaulting to first one available
    available_services = schedule_data |> Map.keys() |> Enum.sort()

    service_id = Map.get(params, "service_id", Enum.at(available_services, 0))

    service = Enum.find(trainsformer_export.services, &(&1.name == service_id))

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

    all_schedules =
      schedule_data
      |> Map.get(service_id)
      |> Enum.map(fn {_trip_id, trip_data} -> trip_data end)
      |> Enum.filter(fn trip_data ->
        trip_data.route_id == route_id and trip_data.direction_id == direction_id
      end)
      |> Enum.map(fn trip_data ->
        {_, new_trip_data} =
          Map.get_and_update(trip_data, :stop_times, fn stop_times ->
            {stop_times, Enum.sort_by(stop_times, & &1.stop_sequence)}
          end)

        new_trip_data
      end)
      |> Enum.sort_by(fn trip_data -> Enum.at(trip_data.stop_times, 0).departure_time end)

    # Combine stops across different trains to get global stop ordering
    stops_in_order =
      Enum.reduce(all_schedules, [], fn trip_data, stop_ids ->
        unseen_stop_ids =
          trip_data.stop_times
          |> Enum.map(& &1.stop_id)
          |> Enum.filter(fn stop_id -> stop_id not in stop_ids end)

        stop_ids ++ unseen_stop_ids
      end)

    train_numbers = Enum.map(all_schedules, & &1.short_name)

    # Combine stop names and stop times into rows
    stop_times_by_stop =
      Enum.map(stops_in_order, fn stop_id ->
        stop_name = Repo.get(Stop, stop_id).name

        stop_times =
          Enum.map(all_schedules, fn trip_data ->
            Enum.find(trip_data.stop_times, &(&1.stop_id == stop_id))
          end)

        {stop_name, stop_times}
      end)

    # Render
    render(conn, :show,
      trainsformer_export_id: export_id,
      disruption_id: trainsformer_export.disruption.id,
      disruption_title: trainsformer_export.disruption.title,
      service_id: service_id,
      service_dates: service.service_dates,
      route_id: route_id,
      direction_id: direction_id,
      available_routes: available_routes,
      train_numbers: train_numbers,
      stop_times_by_stop: stop_times_by_stop
    )
  end
end
