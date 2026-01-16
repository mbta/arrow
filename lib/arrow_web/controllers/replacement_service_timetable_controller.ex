defmodule ArrowWeb.ReplacementServiceTimetableController do
  use ArrowWeb, :controller

  alias Arrow.Disruptions
  alias Arrow.Disruptions.ReplacementService
  alias Arrow.Shuttles

  def show(conn, %{"replacement_service_id" => replacement_service_id} = params) do
    replacement_service =
      replacement_service_id
      |> Disruptions.get_replacement_service!()
      |> ReplacementService.add_timetable()

    available_days_of_week =
      ReplacementService.schedule_service_types()
      |> Enum.reject(&is_nil(replacement_service.timetable[&1]))

    day_of_week =
      if day_of_week = Map.get(params, "day_of_week") do
        String.to_existing_atom(day_of_week)
      else
        Enum.at(available_days_of_week, 0)
      end

    trips_with_times = Map.get(replacement_service.timetable, day_of_week)
    default_direction_id = if(Enum.any?(trips_with_times["0"]), do: "0", else: "1")
    direction_id = Map.get(params, "direction_id", default_direction_id)
    sample_trip = trips_with_times |> Map.get(direction_id) |> Enum.at(0)

    initial_stop_times_by_stop =
      Enum.map(sample_trip, fn stop_time ->
        {stop_time.stop_id
         |> Shuttles.stop_or_gtfs_stop_for_stop_id()
         |> Shuttles.stop_display_name(), stop_time.stop_id, []}
      end)

    stop_times_by_stop =
      trips_with_times
      |> Map.get(direction_id)
      |> Enum.reduce(initial_stop_times_by_stop, fn trip, times_by_stop ->
        trip_stop_times_by_stop = Enum.group_by(trip, & &1.stop_id)

        Enum.map(times_by_stop, fn {stop_display_name, stop_id, times} ->
          [trip_stop_time] = Map.get(trip_stop_times_by_stop, stop_id)

          {stop_display_name, stop_id, times ++ [trip_stop_time.stop_time]}
        end)
      end)

    shuttle_name = replacement_service.shuttle.shuttle_name

    day_of_week_options =
      Enum.map(available_days_of_week, fn day_of_week ->
        case day_of_week do
          :weekday -> {:weekday, "Weekday"}
          :friday -> {:friday, "Friday"}
          :saturday -> {:saturday, "Saturday"}
          :sunday -> {:sunday, "Sunday"}
        end
      end)

    [first_stop, last_stop] =
      [List.first(sample_trip), List.last(sample_trip)]
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
      bidirectional?: Enum.any?(trips_with_times["0"]) and Enum.any?(trips_with_times["1"]),
      day_of_week: day_of_week,
      day_of_week_options: day_of_week_options,
      stop_times_by_stop: stop_times_by_stop,
      num_trips: trips_with_times |> Map.get(direction_id) |> length(),
      first_stop: first_stop,
      last_stop: last_stop
    )
  end
end
