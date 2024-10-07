defmodule Arrow.Shuttles.ShuttleRouteStops do
  use Ecto.Schema
  import Ecto.Changeset

  schema "shuttle_route_stops" do
    field :direction_id, Ecto.Enum, values: [:"0", :"1"]
    field :stop_id, :string
    field :stop_sequence, :integer
    field :time_to_next_stop, :decimal
    field :shuttle_route_id, :id

    timestamps()
  end

  @doc false
  def changeset(shuttle_route_stops, attrs) do
    shuttle_route_stops
    |> cast(attrs, [:direction_id, :stop_id, :stop_sequence, :time_to_next_stop, :shuttle_route_id])
    |> foreign_key_constraint(:shuttle_route_id)
    |> validate_required([:direction_id, :stop_id, :stop_sequence, :time_to_next_stop, :shuttle_route_id])
  end
end
