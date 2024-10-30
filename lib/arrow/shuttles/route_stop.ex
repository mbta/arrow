defmodule Arrow.Shuttles.RouteStop do
  @moduledoc "schema for a shuttle route stop for the db"
  use Ecto.Schema
  import Ecto.Changeset

  schema "shuttle_route_stops" do
    field :direction_id, Ecto.Enum, values: [:"0", :"1"]
    field :stop_sequence, :integer
    field :time_to_next_stop, :decimal
    belongs_to :shuttle_route, Arrow.Shuttles.Route
    belongs_to :stop, Arrow.Shuttles.Stop
    belongs_to :gtfs_stop, Arrow.Gtfs.Stop, type: :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(route_stop, attrs) do
    route_stop
    |> cast(attrs, [:direction_id, :stop_id, :gtfs_stop_id, :stop_sequence, :time_to_next_stop])
    |> validate_required([:direction_id, :stop_sequence, :time_to_next_stop])
    |> assoc_constraint(:shuttle_route)
    |> assoc_constraint(:stop)
    |> assoc_constraint(:gtfs_stop)
  end
end
