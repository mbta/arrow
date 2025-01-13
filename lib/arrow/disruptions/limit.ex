defmodule Arrow.Disruptions.Limit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "limits" do
    field :start_date, :date
    field :end_date, :date
    field :display_route_id, :string, virtual: true
    field :display_start_stop_id, :string, virtual: true
    field :display_end_stop_id, :string, virtual: true
    belongs_to :disruption, Arrow.Disruptions.DisruptionV2
    belongs_to :route, Arrow.Gtfs.Route, type: :string
    belongs_to :start_stop, Arrow.Gtfs.Stop, type: :string
    belongs_to :end_stop, Arrow.Gtfs.Stop, type: :string

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
    |> validate_required([:start_date, :end_date])
    |> assoc_constraint(:route)
    |> assoc_constraint(:start_stop)
    |> assoc_constraint(:end_stop)
  end
end
