defmodule Arrow.Disruptions.ReplacementService do
  @moduledoc """
  Represents replacement service associated with a disruption

  See related: https://github.com/mbta/gtfs_creator/blob/ab5aac52561027aa13888e4c4067a8de177659f6/gtfs_creator2/disruptions/activated_shuttles.py
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Arrow.Disruptions.DisruptionV2
  alias Arrow.Repo.MapForForm
  alias Arrow.Shuttles.Shuttle

  @type t :: %__MODULE__{
          reason: String.t() | nil,
          start_date: Date.t() | nil,
          end_date: Date.t() | nil,
          source_workbook_data: map(),
          source_workbook_filename: String.t(),
          disruption: DisruptionV2.t() | Ecto.Association.NotLoaded.t(),
          shuttle: Shuttle.t() | Ecto.Association.NotLoaded.t()
        }

  schema "replacement_services" do
    field :reason, :string
    field :start_date, :date
    field :end_date, :date
    field :source_workbook_data, MapForForm
    field :source_workbook_filename, :string
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

  @spec trips_with_times(t(), String.t()) :: map()
  def trips_with_times(
        %__MODULE__{source_workbook_data: source_workbook_data, shuttle: shuttle},
        day_of_week
      ) do
    day_of_week_data = Map.get(source_workbook_data, day_of_week <> " headways and runtimes")

    {first_trips, last_trips, headway_periods} =
      Enum.reduce(day_of_week_data, {%{}, %{}, %{}}, fn data,
                                                        {first_trips, last_trips, headway_periods} ->
        case data do
          %{"first_trip_0" => first_trip_0, "first_trip_1" => first_trip_1} ->
            {%{0 => first_trip_0, 1 => first_trip_1}, last_trips, headway_periods}

          %{"last_trip_0" => last_trip_0, "last_trip_1" => last_trip_1} ->
            {first_trips, %{0 => last_trip_0, 1 => last_trip_1}, headway_periods}

          %{"start_time" => start_time} = headway_period ->
            {first_trips, last_trips, Map.put(headway_periods, start_time, headway_period)}
        end
      end)

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

        Enum.map(start_times, fn start_time ->
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
                                                                        {current_stop_time,
                                                                         stop_times} ->
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
                     stop_time: current_stop_time
                   }
                 ]}
            end)

          %{
            stop_times: stop_times
          }
        end)
      end

    %{"0" => direction_0_trips, "1" => direction_1_trips}
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

    final_minutes = hours * 60 + minutes + minutes_to_add

    result_hours = div(final_minutes, 60)
    result_minutes = rem(final_minutes, 60)

    Enum.map_join(
      [result_hours, result_minutes],
      ":",
      &(&1 |> Integer.to_string() |> String.pad_leading(2, "0"))
    )
  end
end
