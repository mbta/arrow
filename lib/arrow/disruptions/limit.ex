defmodule Arrow.Disruptions.Limit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "limits" do
    field :start_date, :date
    field :end_date, :date
    belongs_to :disruption, Arrow.Disruptions.DisruptionV2
    belongs_to :route, Arrow.Gtfs.Route, type: :string
    belongs_to :start_stop, Arrow.Gtfs.Stop, type: :string
    belongs_to :end_stop, Arrow.Gtfs.Stop, type: :string
    has_many :limit_day_of_weeks, Arrow.Limits.LimitDayOfWeek

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(limit, attrs) do
    limit
    |> cast(attrs, [
      :start_date,
      :end_date,
      :route_id,
      :start_stop_id,
      :end_stop_id
    ])
    |> cast_assoc(:limit_day_of_weeks, with: &Arrow.Limits.LimitDayOfWeek.changeset/2)
    |> validate_required([:start_date, :end_date])
    |> assoc_constraint(:route)
    |> assoc_constraint(:start_stop)
    |> assoc_constraint(:end_stop)
  end
end
