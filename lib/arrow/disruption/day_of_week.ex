defmodule Arrow.Disruption.DayOfWeek do
  use Ecto.Schema
  import Ecto.Changeset

  schema "disruption_day_of_weeks" do
    field :start_time, :time
    field :end_time, :time
    field :monday, :boolean, default: false
    field :tuesday, :boolean, default: false
    field :wednesday, :boolean, default: false
    field :thursday, :boolean, default: false
    field :friday, :boolean, default: false
    field :saturday, :boolean, default: false
    field :sunday, :boolean, default: false
    belongs_to :disruption, Arrow.Disruption

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(day_of_week, attrs) do
    day_of_week
    |> cast(attrs, [
      :monday,
      :tuesday,
      :wednesday,
      :thursday,
      :friday,
      :saturday,
      :sunday,
      :start_time,
      :end_time
    ])
  end
end
