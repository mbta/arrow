defmodule Arrow.Gtfs.Trip do
  use Arrow.Gtfs.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: String.t(),
          route: Arrow.Gtfs.Route.t() | Ecto.Association.NotLoaded.t(),
          service: Arrow.Gtfs.Service.t() | Ecto.Association.NotLoaded.t(),
          headsign: String.t(),
          short_name: String.t() | nil,
          direction_id: 0 | 1,
          directions: list(Arrow.Gtfs.Direction.t()) | Ecto.Association.NotLoaded.t(),
          block_id: String.t() | nil,
          shape: Arrow.Gtfs.Shape.t() | Ecto.Association.NotLoaded.t() | nil,
          shape_points: list(Arrow.Gtfs.ShapePoint.t()) | Ecto.Association.NotLoaded.t() | nil,
          wheelchair_accessible: atom,
          route_type: atom | nil,
          # The RoutePattern that this Trip follows.
          route_pattern: Arrow.Gtfs.RoutePattern.t() | Ecto.Association.NotLoaded.t(),
          # The RoutePattern, if any, for which this is the *representative* Trip.
          representing_route_pattern:
            Arrow.Gtfs.RoutePattern.t() | Ecto.Association.NotLoaded.t() | nil,
          bikes_allowed: atom,
          stop_times: list(Arrow.Gtfs.StopTime.t()) | Ecto.Association.NotLoaded.t()
        }

  @wheelchair_accessibility_values Enum.with_index(
                                     ~w[no_information_inherit_from_parent accessible not_accessible]a
                                   )
  @route_type_values Enum.with_index(~w[light_rail heavy_rail commuter_rail bus ferry]a)
  @bike_boarding_values Enum.with_index(~w[no_information bikes_allowed bikes_not_allowed]a)

  schema "gtfs_trips" do
    belongs_to :route, Arrow.Gtfs.Route
    belongs_to :service, Arrow.Gtfs.Service
    field :headsign, :string
    field :short_name, :string
    field :direction_id, :integer
    # Like RoutePattern, we're limited here by Ecto.Schema's lack of support for
    # composite FKs.
    #
    # Same workaround: use the Trip's `direction_id` field to
    # manually look up the relevant Direction from `directions`.
    has_many :directions, through: [:route, :directions]
    field :block_id, :string
    belongs_to :shape, Arrow.Gtfs.Shape
    has_many :shape_points, through: [:shape, :points]
    field :wheelchair_accessible, Arrow.Gtfs.Types.Enum, values: @wheelchair_accessibility_values
    field :route_type, Arrow.Gtfs.Types.Enum, values: @route_type_values
    belongs_to :route_pattern, Arrow.Gtfs.RoutePattern

    has_one :representing_route_pattern, Arrow.Gtfs.RoutePattern,
      foreign_key: :representative_trip_id

    field :bikes_allowed, Arrow.Gtfs.Types.Enum, values: @bike_boarding_values
    has_many :stop_times, Arrow.Gtfs.StopTime, preload_order: [:stop_sequence]
  end

  def changeset(trip, attrs) do
    attrs = remove_table_prefix(attrs, "trip")

    trip
    |> cast(
      attrs,
      ~w[id route_id service_id headsign short_name direction_id block_id shape_id wheelchair_accessible route_type route_pattern_id bikes_allowed]a
    )
    |> validate_required(
      ~w[id route_id service_id headsign direction_id wheelchair_accessible route_pattern_id bikes_allowed]a
    )
    |> validate_inclusion(:direction_id, 0..1)
    |> assoc_constraint(:route)
    |> assoc_constraint(:service)
    |> assoc_constraint(:shape)
    |> assoc_constraint(:route_pattern)
  end
end
