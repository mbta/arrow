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
    |> cast_assoc(:days_of_week)
    |> cast_assoc(:exceptions, with: {Exception, :changeset, [today]})
    |> cast_assoc(:trip_short_names)
    |> validate_not_deleting_past_exception(today)
  end

  @doc false
  @spec changeset(t(), map(), Date.t()) :: Ecto.Changeset.t(t())
  defp changeset(disruption, attrs, today) do
    disruption
    |> cast(attrs, [:id, :start_date, :end_date])
    |> validate_required([:start_date, :end_date])
    |> Arrow.Validations.validate_not_in_past(:start_date, today)
    |> Arrow.Validations.validate_not_in_past(:end_date, today)
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
end
