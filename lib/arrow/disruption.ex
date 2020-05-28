defmodule Arrow.Disruption do
  @moduledoc """
  Disruption: the configuration of trips to which one or more Adjustment(s) is applied.

  - Specific adjustment(s)
  - Dates and times
  - Trip short names (Commuter Rail only)
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Arrow.Disruption.{DayOfWeek, Exception, TripShortName}

  @type t :: %__MODULE__{
          end_date: Date.t() | nil,
          start_date: Date.t() | nil,
          days_of_week: [DayOfWeek.t()] | Ecto.Association.NotLoaded.t(),
          exceptions: [Exception.t()] | Ecto.Association.NotLoaded.t(),
          trip_short_names: [TripShortName.t()] | Ecto.Association.NotLoaded.t(),
          adjustments: [Arrow.Adjustment.t()] | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  schema "disruptions" do
    field :end_date, :date
    field :start_date, :date

    has_many :days_of_week, DayOfWeek, on_replace: :delete
    has_many :exceptions, Exception, on_replace: :delete
    has_many :trip_short_names, TripShortName, on_replace: :delete

    many_to_many :adjustments, Arrow.Adjustment, join_through: "disruption_adjustments"

    timestamps(type: :utc_datetime)
  end

  @doc false
  @spec changeset_for_create(t(), map(), [Arrow.Adjustment.t()], DateTime.t()) ::
          Ecto.Changeset.t()
  def changeset_for_create(disruption, attrs, adjustments, current_time) do
    today = DateTime.to_date(current_time)

    days_of_week =
      for dow <- attrs["days_of_week"] || [],
          do: DayOfWeek.changeset(%DayOfWeek{}, dow)

    exceptions =
      for exception <- attrs["exceptions"] || [],
          do: Exception.changeset(%Exception{}, exception, today)

    trip_short_names =
      for name <- attrs["trip_short_names"] || [],
          do: TripShortName.changeset(%TripShortName{}, name)

    disruption
    |> changeset(attrs, today)
    |> put_assoc(:adjustments, adjustments)
    |> validate_length(:adjustments, min: 1)
    |> put_assoc(:days_of_week, days_of_week)
    |> put_assoc(:exceptions, exceptions)
    |> put_assoc(:trip_short_names, trip_short_names)
  end

  @doc false
  @spec changeset_for_update(t(), map(), DateTime.t()) :: Ecto.Changeset.t(t())
  def changeset_for_update(disruption, attrs, current_time) do
    today = DateTime.to_date(current_time)

    disruption
    |> changeset(attrs, today)
    |> Arrow.Validations.validate_not_changing_past(:start_date, today)
    |> Arrow.Validations.validate_not_changing_past(:end_date, today)
    |> validate_not_deleting_past_exception(today)
    |> validate_not_changing_relationship_in_past(:days_of_week, today)
    |> validate_not_changing_relationship_in_past(:trip_short_names, today)
  end

  @doc false
  @spec changeset(t(), map(), Date.t()) :: Ecto.Changeset.t(t())
  defp changeset(disruption, attrs, today) do
    disruption
    |> cast(attrs, [:id, :start_date, :end_date])
    |> validate_required([:start_date, :end_date])
    |> cast_assoc(:days_of_week)
    |> cast_assoc(:exceptions, with: {Exception, :changeset, [today]})
    |> cast_assoc(:trip_short_names)
    |> Arrow.Validations.validate_not_in_past(:start_date, today)
    |> Arrow.Validations.validate_not_in_past(:end_date, today)
    |> validate_start_date_before_end_date()
    |> validate_days_of_week_between_start_and_end_date()
    |> validate_exceptions_between_start_and_end_date()
    |> validate_exceptions_are_unique()
    |> validate_exceptions_are_applicable()
    |> validate_start_time_before_end_time()
  end

  @spec validate_not_deleting_past_exception(Ecto.Changeset.t(), Date.t()) ::
          Ecto.Changeset.t(t())
  defp validate_not_deleting_past_exception(changeset, today) do
    if deleting_past_exception?(changeset, today) do
      add_error(changeset, :exceptions, "can't be deleted from the past.")
    else
      changeset
    end
  end

  @spec deleting_past_exception?(Ecto.Changeset.t(), Date.t()) :: boolean()
  defp deleting_past_exception?(%{changes: %{exceptions: [_ | _] = exceptions}}, today) do
    Enum.any?(exceptions, fn excp ->
      date = excp.data.excluded_date
      not is_nil(date) and Date.compare(date, today) == :lt and excp.action in [:delete, :replace]
    end)
  end

  defp deleting_past_exception?(_, _), do: false

  @spec validate_not_changing_relationship_in_past(Ecto.Changeset.t(t()), atom(), Date.t()) ::
          Ecto.Changeset.t(t())
  defp validate_not_changing_relationship_in_past(changeset, relationship, today) do
    start_date = get_field(changeset, :start_date)

    if not is_nil(start_date) and Date.compare(start_date, today) == :lt and
         get_change(changeset, relationship, []) != [] do
      add_error(changeset, relationship, "can't be changed because start date is in the past.")
    else
      changeset
    end
  end

  @spec validate_start_date_before_end_date(Ecto.Changeset.t(t())) :: Ecto.Changeset.t(t())
  defp validate_start_date_before_end_date(changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)

    cond do
      is_nil(start_date) or is_nil(end_date) ->
        changeset

      Date.compare(start_date, end_date) == :gt ->
        add_error(changeset, :start_date, "can't be after end date.")

      true ->
        changeset
    end
  end

  @spec validate_days_of_week_between_start_and_end_date(Ecto.Changeset.t(t())) :: Ecto.Changeset.t(t())
  defp validate_days_of_week_between_start_and_end_date(changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)
    days_of_week = get_field(changeset, :days_of_week)

    cond do
      is_nil(start_date) or is_nil(end_date) ->
        changeset

      Date.diff(end_date, start_date) >= 6 ->
        changeset

      Enum.all?(days_of_week, fn day ->
        Enum.member?(
          Enum.map(Date.range(start_date, end_date), fn date -> Date.day_of_week(date) end),
          DayOfWeek.day_number(day)
        )
      end) ->
        changeset

      true ->
        add_error(changeset, :days_of_week, "should fall between start and end dates")
    end
  end

  @spec validate_exceptions_are_unique(Ecto.Changeset.t(t())) :: Ecto.Changeset.t(t())
  defp validate_exceptions_are_unique(changeset) do
    exceptions = get_field(changeset, :exceptions)

    if Enum.uniq_by(exceptions, fn %{excluded_date: excluded_date} -> excluded_date end) ==
         exceptions do
      changeset
    else
      add_error(changeset, :exceptions, "should be unique")
    end
  end

  @spec validate_exceptions_between_start_and_end_date(Ecto.Changeset.t(t())) :: Ecto.Changeset.t(t())
  defp validate_exceptions_between_start_and_end_date(changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)
    exceptions = get_field(changeset, :exceptions)

    if Enum.all?(exceptions, fn exception ->
         Enum.member?([:lt, :eq], Date.compare(start_date, exception.excluded_date)) and
           Enum.member?([:gt, :eq], Date.compare(end_date, exception.excluded_date))
       end) do
      changeset
    else
      add_error(changeset, :exceptions, "should fall between start and end dates")
    end
  end

  @spec validate_exceptions_are_applicable(Ecto.Changeset.t(t())) ::
          Ecto.Changeset.t(t())
  defp validate_exceptions_are_applicable(changeset) do
    days_of_week = get_field(changeset, :days_of_week)
    exceptions = get_field(changeset, :exceptions)

    day_of_week_numbers = Enum.map(days_of_week, fn x -> DayOfWeek.day_number(x) end)

    if Enum.all?(exceptions, fn exception ->
         Enum.member?(day_of_week_numbers, Date.day_of_week(exception.excluded_date))
       end) do
      changeset
    else
      add_error(changeset, :exceptions, "should be applicable to days of week")
    end
  end

  @spec validate_start_time_before_end_time(Ecto.Changeset.t(t())) :: Ecto.Changeset.t(t())
  defp validate_start_time_before_end_time(changeset) do
    days_of_week = get_field(changeset, :days_of_week)

    if Enum.any?(days_of_week, fn day ->
         not (is_nil(day.start_time) or is_nil(day.end_time)) and
           not (Time.compare(day.start_time, day.end_time) == :lt)
       end) do
      add_error(changeset, :days_of_week, "start_time should be before end_time")
    else
      changeset
    end
  end
end
