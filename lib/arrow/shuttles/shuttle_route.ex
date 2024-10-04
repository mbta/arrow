defmodule Arrow.Shuttles.ShuttleRoute do
  use Ecto.Schema
  import Ecto.Changeset

  schema "shuttle_routes" do
    field :suffix, :string
    field :destination, :string
    field :direction_id, Ecto.Enum, values: [:"0", :"1"]
    field :direction_desc, :string
    field :waypoint, :string
    field :shuttle_id, :id
    field :shape_id, :id

    timestamps()
  end

  @doc false
  def changeset(shuttle_route, attrs) do
    shuttle_route
    |> cast(attrs, [:direction_id, :direction_desc, :destination, :waypoint, :suffix])
    |> validate_required([:direction_id, :direction_desc, :destination, :waypoint, :suffix])
  end
end
