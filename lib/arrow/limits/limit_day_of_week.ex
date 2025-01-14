defmodule Arrow.Limits.LimitDayOfWeek do
  use Ecto.Schema
  import Ecto.Changeset

  schema "limit_day_of_weeks" do
    field :day_name, :string
    field :start_time, :time
    field :end_time, :time
    belongs_to :limit, Arrow.Disruptions.Limit

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(limit_day_of_week, attrs) do
    limit_day_of_week
    |> cast(attrs, [:day_name, :start_time, :end_time, :limit_id])
    |> validate_required([:day_name, :start_time, :end_time])
    |> assoc_constraint(:limit)
  end
end
