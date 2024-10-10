defmodule Arrow.Shuttles.RouteStop do
  use Ecto.Schema
  import Ecto.Changeset

  schema "shuttle_route_stops" do
    field :direction_id, Ecto.Enum, values: [:"0", :"1"]
    field :stop_id, :string
    field :stop_sequence, :integer
    field :time_to_next_stop, :decimal
    field :shuttle_route_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(route_stop, attrs) do
    route_stop
    |> cast(attrs, [:direction_id, :stop_id, :stop_sequence, :time_to_next_stop])
    |> validate_required([:direction_id, :stop_id, :stop_sequence, :time_to_next_stop])
  end
end
