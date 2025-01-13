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
    belongs_to :route, Arrow.Gtfs.Route
    belongs_to :start_stop, Arrow.Gtfs.Stop
    belongs_to :end_stop, Arrow.Gtfs.Stop

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(limit, attrs) do
    limit
    |> cast(attrs, [:start_date, :end_date])
    |> validate_required([:start_date, :end_date])
  end
end
