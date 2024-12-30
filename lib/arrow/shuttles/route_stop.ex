defmodule Arrow.Shuttles.RouteStop do
  @moduledoc "schema for a shuttle route stop for the db"
  use Ecto.Schema
  import Ecto.Changeset

  alias Arrow.Gtfs.Stop, as: GtfsStop
  alias Arrow.Shuttles
  alias Arrow.Shuttles.Stop

  @type t :: %__MODULE__{
          direction_id: :"0" | :"1",
          stop_sequence: integer(),
          time_to_next_stop: float(),
          display_stop_id: String.t(),
          display_stop: Arrow.Shuttles.Stop.t() | Arrow.Gtfs.Stop.t() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil,
          shuttle_route: Arrow.Gtfs.Level.t() | Ecto.Association.NotLoaded.t() | nil,
          stop: Arrow.Shuttles.Stop.t() | Ecto.Association.NotLoaded.t() | nil,
          gtfs_stop: Arrow.Gtfs.Stop.t() | Ecto.Association.NotLoaded.t() | nil
        }

  schema "shuttle_route_stops" do
    field :direction_id, Ecto.Enum, values: [:"0", :"1"]
    field :stop_sequence, :integer
    field :time_to_next_stop, :decimal
    field :display_stop_id, :string, virtual: true
    field :display_stop, :map, virtual: true
    belongs_to :shuttle_route, Arrow.Shuttles.Route
    belongs_to :stop, Arrow.Shuttles.Stop
    belongs_to :gtfs_stop, Arrow.Gtfs.Stop, type: :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(route_stop, attrs) do
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

    change =
      if display_stop_id = Ecto.Changeset.get_change(change, :display_stop_id) do
        {stop_id, gtfs_stop_id, stop, error} =
          case Shuttles.stop_or_gtfs_stop_for_stop_id(display_stop_id) do
            %Stop{id: id} = stop -> {id, nil, stop, nil}
            %GtfsStop{id: id} = stop -> {nil, id, stop, nil}
            nil -> {nil, nil, nil, "not a valid stop ID"}
          end

        change =
          change
          |> change(stop_id: stop_id)
          |> change(gtfs_stop_id: gtfs_stop_id)
          |> change(display_stop: stop)

        if is_nil(error) do
          change
        else
          add_error(change, :display_stop_id, error)
        end
      else
        change
      end

    change
    |> validate_required([:direction_id, :stop_sequence])
    |> assoc_constraint(:shuttle_route)
    |> assoc_constraint(:stop)
    |> assoc_constraint(:gtfs_stop)
  end
end
