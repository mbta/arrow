defmodule Arrow.Shuttles.RouteStop do
  @moduledoc "schema for a shuttle route stop for the db"
  use Ecto.Schema
  import Ecto.Changeset

  alias Arrow.Gtfs.Stop, as: GtfsStop
  alias Arrow.Shuttles
  alias Arrow.Shuttles.Stop

  schema "shuttle_route_stops" do
    field :direction_id, Ecto.Enum, values: [:"0", :"1"]
    field :stop_sequence, :integer
    field :time_to_next_stop, :decimal
    field :display_stop_id, :string, virtual: true
    belongs_to :shuttle_route, Arrow.Shuttles.Route
    belongs_to :stop, Arrow.Shuttles.Stop
    belongs_to :gtfs_stop, Arrow.Gtfs.Stop, type: :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(route_stop, attrs) do
    {stop_id, gtfs_stop_id, error} =
      case Shuttles.stop_or_gtfs_stop_for_stop_id(
             attrs["display_stop_id"] || route_stop.display_stop_id
           ) do
        %Stop{id: id} -> {id, nil, nil}
        %GtfsStop{id: id} -> {nil, id, nil}
        nil -> {nil, nil, "not a valid stop ID"}
      end

    change =
      route_stop
      |> cast(attrs, [
        :direction_id,
        :stop_id,
        :gtfs_stop_id,
        :stop_sequence,
        :time_to_next_stop,
        :display_stop_id
      ])
      |> change(stop_id: stop_id)
      |> change(gtfs_stop_id: gtfs_stop_id)
      |> validate_required([:direction_id, :stop_sequence])
      |> assoc_constraint(:shuttle_route)
      |> assoc_constraint(:stop)
      |> assoc_constraint(:gtfs_stop)

    if is_nil(error) do
      change
    else
      add_error(change, :display_stop_id, error)
    end
  end
end
