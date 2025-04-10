defmodule Arrow.Disruptions.ReplacementService do
  @moduledoc """
  Represents replacement service associated with a disruption

  See related: https://github.com/mbta/gtfs_creator/blob/ab5aac52561027aa13888e4c4067a8de177659f6/gtfs_creator2/disruptions/activated_shuttles.py
  """
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias Arrow.Disruptions.DisruptionV2
  alias Arrow.Repo
  alias Arrow.Repo.MapForForm
  alias Arrow.Shuttles
  alias Arrow.Shuttles.Shuttle

  @type stop_time :: %{stop_id: String.t(), stop_time: String.t()}
  @type direction_id :: String.t()
  @type timetable ::
          %{direction_id() => list(stop_time()), direction_id() => list(stop_time())} | nil

  @type t :: %__MODULE__{
          reason: String.t() | nil,
          start_date: Date.t() | nil,
          end_date: Date.t() | nil,
          source_workbook_data: map(),
          source_workbook_filename: String.t(),
          disruption: DisruptionV2.t() | Ecto.Association.NotLoaded.t(),
          shuttle: Shuttle.t() | Ecto.Association.NotLoaded.t(),
          timetable: %{weekday: timetable(), saturday: timetable(), sunday: timetable()} | nil
        }

  @service_type_to_workbook_abbreviation %{
    :weekday => "WKDY",
    :sunday => "SUN",
    :saturday => "SAT"
  }

  schema "replacement_services" do
    field :reason, :string
    field :start_date, :date
    field :end_date, :date
    field :source_workbook_data, MapForForm
    field :source_workbook_filename, :string
    field :timetable, :map, virtual: true
    belongs_to :disruption, DisruptionV2
    belongs_to :shuttle, Shuttle

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(replacement_service, attrs) do
    replacement_service
    |> cast(attrs, [
      :reason,
      :start_date,
      :end_date,
      :source_workbook_data,
      :source_workbook_filename,
      :shuttle_id,
      :disruption_id
    ])
    |> validate_required([
      :start_date,
      :end_date,
      :source_workbook_data,
      :source_workbook_filename,
      :disruption_id,
      :shuttle_id
    ])
    |> validate_start_date_before_end_date()
    |> assoc_constraint(:shuttle)
    |> assoc_constraint(:disruption)
  end

  @spec validate_start_date_before_end_date(Ecto.Changeset.t(t())) :: Ecto.Changeset.t(t())
  defp validate_start_date_before_end_date(changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)

    cond do
      is_nil(start_date) or is_nil(end_date) ->
        changeset

      not (Date.compare(start_date, end_date) == :lt) ->
        add_error(changeset, :start_date, "start date should be before end date")

      true ->
        changeset
    end
  end

  def add_timetable(%__MODULE__{} = replacement_service) do
    timetable =
      schedule_service_types()
      |> Enum.map(fn service_type ->
        {service_type, trips_with_times(replacement_service, service_type)}
      end)
      |> Enum.into(%{})

    %__MODULE__{replacement_service | timetable: timetable}
  end

  @spec get_replacement_services_with_timetables(Date.t(), Date.t()) ::
          list(%{
            reason: String.t(),
            disruption: DisruptionV2.t(),
            shuttle: Shuttle.t(),
            timetable: map()
          })
  def get_replacement_services_with_timetables(start_date, end_date) do
    from(r in __MODULE__,
      join: s in assoc(r, :shuttle),
      join: d in assoc(r, :disruption),
      join: sr in assoc(s, :routes),
      join: rs in assoc(sr, :route_stops),
      left_join: gs in assoc(rs, :gtfs_stop),
      left_join: st in assoc(rs, :stop),
      where: r.start_date <= ^end_date and r.end_date >= ^start_date and d.is_active,
      preload: [:disruption, shuttle: {s, routes: {sr, route_stops: [:gtfs_stop, :stop]}}]
    )
    |> Repo.all()
    |> Enum.map(&add_timetable/1)
  end

  @spec schedule_service_types :: list(atom())
  def schedule_service_types, do: [:weekday, :saturday, :sunday]

  @spec first_last_trip_times(t(), list(atom())) :: %{
          atom() => %{
            first_trips: %{0 => String.t(), 1 => String.t()},
            last_trips: %{0 => String.t(), 1 => String.t()}
          }
        }
  def first_last_trip_times(
        %__MODULE__{} = replacement_service,
        schedule_service_types \\ schedule_service_types()
      ) do
    schedule_service_types
    |> Enum.map(fn service_type ->
      service_type_abbreviation = Map.get(@service_type_to_workbook_abbreviation, service_type)

      day_of_week_data =
        Map.get(
          replacement_service.source_workbook_data,
          workbook_column_from_day_of_week(service_type_abbreviation)
        )

      {service_type, day_of_week_data}
    end)
    |> Enum.reject(&match?({_service_type, nil}, &1))
    |> Map.new(fn {service_type, day_of_week_data} ->
      {first_trips, last_trips, _headway_periods} =
        Enum.reduce(day_of_week_data, {%{}, %{}, %{}}, &reduce_workbook_data/2)

      {service_type, %{first_trips: first_trips, last_trips: last_trips}}
    end)
  end

  defp trips_with_times(
         %__MODULE__{source_workbook_data: workbook_data} = replacement_service,
         service_type_atom
       ) do
    service_type_abbreviation = Map.get(@service_type_to_workbook_abbreviation, service_type_atom)

    if day_of_week_data =
         Map.get(workbook_data, workbook_column_from_day_of_week(service_type_abbreviation)) do
      do_trips_with_times(replacement_service, day_of_week_data)
    else
      nil
    end
  end

  defp reduce_workbook_data(
         %{"first_trip_0" => first_trip_0, "first_trip_1" => first_trip_1},
         {_first_trips, last_trips, headway_periods}
       ) do
    {%{0 => first_trip_0, 1 => first_trip_1}, last_trips, headway_periods}
  end

  defp reduce_workbook_data(
         %{"last_trip_0" => last_trip_0, "last_trip_1" => last_trip_1},
         {first_trips, _last_trips, headway_periods}
       ) do
    {first_trips, %{0 => last_trip_0, 1 => last_trip_1}, headway_periods}
  end

  defp reduce_workbook_data(
         %{"start_time" => start_time} = headway_period,
         {first_trips, last_trips, headway_periods}
       ) do
    {first_trips, last_trips, Map.put(headway_periods, start_time, headway_period)}
  end

  defp do_trips_with_times(
         %__MODULE__{shuttle: shuttle},
         day_of_week_data
       ) do
    # to do: find a way to ensure that display_stop_id is always populate on every shuttle route stop
    # regardless of from where the shuttle comes
    # (e.g. if a shuttle comes from a join, it should still have display_stop_id populated)
    shuttle = Shuttles.populate_display_stop_ids(shuttle)

    {first_trips, last_trips, headway_periods} =
      Enum.reduce(day_of_week_data, {%{}, %{}, %{}}, &reduce_workbook_data/2)

    [direction_0_trips, direction_1_trips] =
      for direction_id <- [0, 1] do
        first_trip = first_trips[direction_id]
        last_trip = last_trips[direction_id]

        start_times =
          Stream.unfold(first_trip, &unfold_trip_start_times(&1, last_trip, headway_periods))

        shuttle_route =
          Enum.find(
            shuttle.routes,
            &(&1.direction_id == direction_id |> Integer.to_string() |> String.to_existing_atom())
          )

        Enum.map(
          start_times,
          &build_stop_times_for_start_time(&1, direction_id, headway_periods, shuttle_route)
        )
      end

    %{"0" => direction_0_trips, "1" => direction_1_trips}
  end

  defp workbook_column_from_day_of_week(day_of_week), do: day_of_week <> " headways and runtimes"

  defp build_stop_times_for_start_time(start_time, direction_id, headway_periods, shuttle_route) do
    total_runtime =
      headway_periods
      |> Map.get(
        start_of_hour(start_time),
        find_period_by_time_range(headway_periods, start_time)
      )
      |> Map.get("running_time_#{direction_id}")

    total_times_to_next_stop =
      Enum.reduce(shuttle_route.route_stops, 0, fn route_stop, acc ->
        if is_nil(route_stop.time_to_next_stop) do
          acc
        else
          acc + Decimal.to_float(route_stop.time_to_next_stop)
        end
      end)

    {_, stop_times} =
      Enum.reduce(shuttle_route.route_stops, {start_time, []}, fn route_stop,
                                                                  {current_stop_time, stop_times} ->
        {if is_nil(route_stop.time_to_next_stop) do
           current_stop_time
         else
           time_to_next_stop = Decimal.to_float(route_stop.time_to_next_stop)

           add_minutes(
             current_stop_time,
             round(time_to_next_stop / total_times_to_next_stop * total_runtime)
           )
         end,
         stop_times ++
           [
             %{
               stop_id: Shuttles.get_display_stop_id(route_stop),
               stop_time: "#{current_stop_time}:00"
             }
           ]}
      end)

    stop_times
  end

  defp unfold_trip_start_times(:stop, _last_trip_start_time, _headway_periods) do
    nil
  end

  defp unfold_trip_start_times(last_trip_start_time, last_trip_start_time, _headway_periods) do
    {last_trip_start_time, :stop}
  end

  defp unfold_trip_start_times(trip_start_time, last_trip_start_time, headway_periods) do
    headway =
      headway_periods
      |> Map.get_lazy(start_of_hour(trip_start_time), fn ->
        find_period_by_time_range(headway_periods, trip_start_time)
      end)
      |> Map.get("headway")

    # Ensure that the sequence ends with the last trip time indicated in the spreadsheet,
    # even if it doesn't line up exactly with the headway cadence.
    next_trip_start_time =
      min(add_minutes(trip_start_time, headway), last_trip_start_time)

    {trip_start_time, next_trip_start_time}
  end

  defp find_period_by_time_range(headway_periods, first_trip_start_time) do
    headway_periods
    |> Enum.find({nil, nil}, fn {_, headway_period} ->
      headway_period["start_time"] <= first_trip_start_time and
        headway_period["end_time"] >= first_trip_start_time
    end)
    |> elem(1)
  end

  defp start_of_hour(gtfs_time_string) do
    String.slice(gtfs_time_string, 0..1) <> ":00"
  end

  defp add_minutes(gtfs_time_string, minutes_to_add) do
    [hours, minutes] = gtfs_time_string |> String.split(":") |> Enum.map(&String.to_integer/1)

    final_minutes = ceil(hours * 60 + minutes + minutes_to_add)

    result_hours = div(final_minutes, 60)
    result_minutes = rem(final_minutes, 60)

    Enum.map_join(
      [result_hours, result_minutes],
      ":",
      &(&1 |> Integer.to_string() |> String.pad_leading(2, "0"))
    )
  end
end
