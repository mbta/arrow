defmodule ArrowWeb.TimetableController do
  use ArrowWeb, :controller

  alias Arrow.Disruptions
  alias Arrow.Shuttles

  def show(conn, %{"replacement_service_id" => replacement_service_id} = params) do
    replacement_service = Disruptions.get_replacement_service!(replacement_service_id)

    available_days_of_week = Disruptions.days_of_week_for_replacement_service(replacement_service)

    day_of_week = Map.get(params, "day_of_week", Enum.at(available_days_of_week, 0))

    trips_with_times =
      Disruptions.replacement_service_trips_with_times(replacement_service, day_of_week)

    direction_id = Map.get(params, "direction_id", "0")

    sample_trip = trips_with_times |> Map.get(direction_id) |> Enum.at(0)

    initial_stop_times_by_stop =
      Enum.map(sample_trip.stop_times, fn stop_time ->
        {stop_time.stop_id
         |> Shuttles.stop_or_gtfs_stop_for_stop_id()
         |> Shuttles.stop_display_name(), stop_time.stop_id, []}
      end)

    stop_times_by_stop =
      trips_with_times
      |> Map.get(direction_id)
      |> Enum.reduce(initial_stop_times_by_stop, fn trip, times_by_stop ->
        trip_stop_times_by_stop = Enum.group_by(trip.stop_times, & &1.stop_id)

        Enum.map(times_by_stop, fn {stop_display_name, stop_id, times} ->
          [trip_stop_time] = Map.get(trip_stop_times_by_stop, stop_id)

          {stop_display_name, stop_id, times ++ [trip_stop_time.stop_time]}
        end)
      end)

    shuttle_name = replacement_service.shuttle.shuttle_name

    day_of_week_options =
      Enum.map(available_days_of_week, fn day_of_week ->
        case day_of_week do
          "WKDY" -> {"WKDY", "Weekday"}
          "SAT" -> {"SAT", "Saturday"}
          "SUN" -> {"SUN", "Sunday"}
        end
      end)

    [first_stop, last_stop] =
      [List.first(sample_trip.stop_times), List.last(sample_trip.stop_times)]
      |> Enum.map(fn stop ->
        stop
        |> Map.get(:stop_id)
        |> Shuttles.stop_or_gtfs_stop_for_stop_id()
        |> Shuttles.stop_display_name()
      end)

    render(conn, :show,
      replacement_service_id: replacement_service,
      shuttle_name: shuttle_name,
      direction_id: direction_id,
      day_of_week: day_of_week,
      day_of_week_options: day_of_week_options,
      stop_times_by_stop: stop_times_by_stop,
      num_trips: trips_with_times |> Map.get(direction_id) |> length(),
      first_stop: first_stop,
      last_stop: last_stop
    )
  end
end
