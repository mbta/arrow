defmodule Arrow.Disruption.DayOfWeek do
  use Ecto.Schema
  import Ecto.Changeset

  schema "disruption_day_of_weeks" do
    field :day_name, :string
    field :start_time, :time
    field :end_time, :time
    belongs_to :disruption, Arrow.Disruption

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(day_of_week, attrs) do
    day_of_week
    |> cast(attrs, [:day_name, :start_time, :end_time])
    |> validate_inclusion(:day_name, [
      "monday",
      "tuesday",
      "wednesday",
      "thursday",
      "friday",
      "saturday",
      "sunday"
    ])
    |> unique_constraint(:day_name, name: "unique_disruption_weekday")
  end
end
