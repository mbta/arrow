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
  @type timetable :: %{
          optional(:weekday) => stop_time(),
          optional(:saturday) => stop_time(),
          optional(:sunday) => stop_time()
        }

  @type t :: %__MODULE__{
          reason: String.t() | nil,
          start_date: Date.t() | nil,
          end_date: Date.t() | nil,
          source_workbook_data: map(),
          source_workbook_filename: String.t(),
          disruption: DisruptionV2.t() | Ecto.Association.NotLoaded.t(),
          shuttle: Shuttle.t() | Ecto.Association.NotLoaded.t(),
          timetable: timetable() | nil
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
      # where: r.start_date >= ^start_date and r.end_date <= ^end_date,
      join: s in assoc(r, :shuttle),
      join: d in assoc(r, :disruption),
      join: sr in assoc(s, :routes),
      join: rs in assoc(sr, :route_stops),
      left_join: gs in assoc(rs, :gtfs_stop),
      left_join: st in assoc(rs, :stop),
      where: r.start_date <= ^end_date and r.end_date >= ^start_date,
      preload: [:disruption, shuttle: {s, routes: {sr, route_stops: [:gtfs_stop, :stop]}}]
    )
    |> Repo.all()
    |> Enum.map(&add_timetable/1)
  end

  @spec schedule_service_types :: list(atom())
  def schedule_service_types, do: [:weekday, :saturday, :sunday]

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
        start_times =
          do_make_trip_start_times(
            first_trips[direction_id],
            last_trips[direction_id],
            [],
            headway_periods
          )

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
      |> Map.get(start_of_hour(start_time))
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
               stop_id: route_stop.display_stop_id,
               stop_time: "#{current_stop_time}:00"
             }
           ]}
      end)

    stop_times
  end

  defp do_make_trip_start_times(
         first_trip_start_time,
         last_trip_start_time,
         trip_start_times,
         _headway_periods
       )
       when first_trip_start_time > last_trip_start_time,
       do: trip_start_times

  defp do_make_trip_start_times(
         first_trip_start_time,
         last_trip_start_time,
         trip_start_times,
         headway_periods
       ) do
    headway =
      headway_periods |> Map.get(start_of_hour(first_trip_start_time)) |> Map.get("headway")

    first_trip_start_time
    |> add_minutes(headway)
    |> do_make_trip_start_times(
      last_trip_start_time,
      trip_start_times ++ [first_trip_start_time],
      headway_periods
    )
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
