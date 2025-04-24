defmodule Arrow.Shuttles.Route do
  @moduledoc "schema for a shuttle route for the db"
  use Ecto.Schema
  import Ecto.Changeset

  alias Arrow.Shuttles

  @direction_0_desc_values [:Outbound, :South, :West]
  @direction_1_desc_values [:Inbound, :North, :East]

  def direction_desc_values, do: @direction_0_desc_values ++ @direction_1_desc_values

  def direction_desc_values(direction_id) when direction_id in [:"0", "0"],
    do: @direction_0_desc_values

  def direction_desc_values(direction_id) when direction_id in [:"1", "1"],
    do: @direction_1_desc_values

  @type t :: %__MODULE__{
          suffix: String.t(),
          destination: String.t(),
          direction_id: :"0" | :"1",
          direction_desc: :Inbound | :Outbound | :North | :South | :East | :West,
          waypoint: String.t(),
          shuttle: Shuttles.Shuttle.t() | Ecto.Association.NotLoaded.t() | nil,
          shape: Shuttles.Shape.t() | Ecto.Association.NotLoaded.t() | nil,
          route_stops: [Shuttles.RouteStop.t()] | Ecto.Association.NotLoaded.t() | nil
        }

  schema "shuttle_routes" do
    field :suffix, :string
    field :destination, :string
    field :direction_id, Ecto.Enum, values: [:"0", :"1"]
    field :direction_desc, Ecto.Enum, values: @direction_0_desc_values ++ @direction_1_desc_values
    field :waypoint, :string
    belongs_to :shuttle, Arrow.Shuttles.Shuttle
    belongs_to :shape, Arrow.Shuttles.Shape

    has_many :route_stops, Arrow.Shuttles.RouteStop,
      foreign_key: :shuttle_route_id,
      preload_order: [asc: :stop_sequence],
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(route, attrs) do
    route
    |> cast(attrs, [:direction_id, :direction_desc, :destination, :waypoint, :suffix, :shape_id])
    |> cast_assoc(:route_stops,
      with: &Arrow.Shuttles.RouteStop.changeset/2,
      sort_param: :route_stops_sort,
      drop_param: :route_stops_drop
    )
    |> validate_required([:direction_id, :direction_desc, :destination])
    |> assoc_constraint(:shape)
  end
end
