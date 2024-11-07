defmodule Arrow.Shuttles.Route do
  @moduledoc "schema for a shuttle route for the db"
  use Ecto.Schema
  import Ecto.Changeset

  schema "shuttle_routes" do
    field :suffix, :string
    field :destination, :string
    field :direction_id, Ecto.Enum, values: [:"0", :"1"]
    field :direction_desc, :string
    field :waypoint, :string
    belongs_to :shuttle, Arrow.Shuttles.Shuttle
    belongs_to :shape, Arrow.Shuttles.Shape
    has_many :route_stops, Arrow.Shuttles.RouteStop, foreign_key: :shuttle_route_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(route, attrs) do
    route
    |> cast(attrs, [:direction_id, :direction_desc, :destination, :waypoint, :suffix, :shape_id])
    |> validate_required([:direction_id, :direction_desc, :destination])
    |> assoc_constraint(:shape)
  end
end
