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
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(disruption, attrs) do
    disruption
    |> cast(attrs, [:id, :start_date, :end_date])
    |> validate_required([:start_date, :end_date])
  end

  @doc false
  @spec changeset_for_create(t(), map(), [Arrow.Adjustment.t()]) :: Ecto.Changeset.t()
  def changeset_for_create(disruption, attrs, adjustments) do
    {days_of_week, exceptions, trip_short_names} = assoc_changesets(attrs)

    disruption
    |> changeset(attrs)
    |> put_assoc(:adjustments, adjustments)
    |> validate_length(:adjustments, min: 1)
    |> put_assoc(:days_of_week, days_of_week)
    |> put_assoc(:exceptions, exceptions)
    |> put_assoc(:trip_short_names, trip_short_names)
  end

  @doc false
  @spec changeset_for_update(t(), map()) :: Ecto.Changeset.t()
  def changeset_for_update(disruption, attrs) do
    {days_of_week, exceptions, trip_short_names} = assoc_changesets(attrs)

    disruption
    |> changeset(attrs)
    |> cast_assoc(:days_of_week, days_of_week)
    |> cast_assoc(:exceptions, exceptions)
    |> cast_assoc(:trip_short_names, trip_short_names)
  end

  @spec assoc_changesets(map()) ::
          {[Ecto.Changeset.t()], [Ecto.Changeset.t()], [Ecto.Changeset.t()]}
  defp assoc_changesets(attrs) do
    days_of_week =
      for dow <- attrs["days_of_week"] || [],
          do: DayOfWeek.changeset(%DayOfWeek{}, dow)

    exceptions =
      for exception <- attrs["exceptions"] || [],
          do: Exception.changeset(%Exception{}, exception)

    trip_short_names =
      for name <- attrs["trip_short_names"] || [],
          do: TripShortName.changeset(%TripShortName{}, name)

    {days_of_week, exceptions, trip_short_names}
  end
end
