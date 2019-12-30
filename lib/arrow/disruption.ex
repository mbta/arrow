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

  schema "disruptions" do
    field :end_date, :date
    field :start_date, :date

    has_many :days_of_week, DayOfWeek
    has_many :exceptions, Exception
    has_many :trip_short_names, TripShortName
    many_to_many :adjustments, Arrow.Adjustment, join_through: "disruption_adjustments"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(disruption, attrs) do
    days_of_week =
      for dow <- attrs[:days_of_week] || [],
          do: DayOfWeek.changeset(%DayOfWeek{}, dow)

    exceptions =
      for exception <- attrs[:exceptions] || [],
          do: Exception.changeset(%Exception{}, %{excluded_date: exception})

    trip_short_names =
      for name <- attrs[:trip_short_names] || [],
          do: TripShortName.changeset(%TripShortName{}, %{trip_short_name: name})

    disruption
    |> cast(attrs, [:start_date, :end_date])
    |> validate_required([:start_date, :end_date])
    |> put_assoc(:adjustments, attrs[:adjustments] || [])
    |> put_assoc(:days_of_week, days_of_week)
    |> put_assoc(:exceptions, exceptions)
    |> put_assoc(:trip_short_names, trip_short_names)
  end
end
