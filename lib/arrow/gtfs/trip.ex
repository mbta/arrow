defmodule Arrow.Gtfs.Trip do
  @moduledoc """
  Represents a row from trips.txt.

  Changeset is intended for use only in CSV imports--
  table contents should be considered read-only otherwise.
  """
  use Arrow.Gtfs.Schema

  import Ecto.Changeset

  alias Arrow.Gtfs.Importable
  alias Arrow.Gtfs.Route
  alias Arrow.Gtfs.RoutePattern
  alias Arrow.Gtfs.Service
  alias Arrow.Gtfs.Shape
  alias Arrow.Gtfs.StopTime
  alias Ecto.Association.NotLoaded

  @type t :: %__MODULE__{
          id: String.t(),
          route: Route.t() | NotLoaded.t(),
          service: Service.t() | NotLoaded.t(),
          headsign: String.t(),
          short_name: String.t() | nil,
          direction_id: 0 | 1,
          directions: list(Arrow.Gtfs.Direction.t()) | NotLoaded.t(),
          block_id: String.t() | nil,
          shape: Shape.t() | NotLoaded.t() | nil,
          shape_points: list(Arrow.Gtfs.ShapePoint.t()) | NotLoaded.t() | nil,
          wheelchair_accessible: atom,
          route_type: atom | nil,
          # The RoutePattern that this Trip follows.
          route_pattern: RoutePattern.t() | NotLoaded.t(),
          # The RoutePattern, if any, for which this is the *representative* Trip.
          representing_route_pattern: RoutePattern.t() | NotLoaded.t() | nil,
          bikes_allowed: atom,
          stop_times: list(StopTime.t()) | NotLoaded.t()
        }

  @wheelchair_accessibility_values Enum.with_index(~w[no_information_inherit_from_parent accessible not_accessible]a)
  @route_type_values Enum.with_index(~w[light_rail heavy_rail commuter_rail bus ferry]a)
  @bike_boarding_values Enum.with_index(~w[no_information bikes_allowed bikes_not_allowed]a)

  schema "gtfs_trips" do
    belongs_to :route, Route
    belongs_to :service, Service
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
    belongs_to :shape, Shape
    has_many :shape_points, through: [:shape, :points]
    field :wheelchair_accessible, Ecto.Enum, values: @wheelchair_accessibility_values
    field :route_type, Ecto.Enum, values: @route_type_values
    belongs_to :route_pattern, RoutePattern

    has_one :representing_route_pattern, RoutePattern, foreign_key: :representative_trip_id

    field :bikes_allowed, Ecto.Enum, values: @bike_boarding_values
    has_many :stop_times, StopTime, preload_order: [:stop_sequence]
  end

  def changeset(trip, attrs) do
    attrs =
      attrs
      |> remove_table_prefix("trip")
      |> values_to_int(~w[wheelchair_accessible route_type bikes_allowed])

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

  @impl Importable
  def filenames, do: ["trips.txt"]

  @impl Importable
  def import(unzip) do
    Importable.import_using_copy(
      __MODULE__,
      unzip,
      header_mappings: %{
        "trip_id" => "id",
        "trip_headsign" => "headsign",
        "trip_short_name" => "short_name",
        "trip_route_type" => "route_type"
      },
      header_order: [
        "route_id",
        "service_id",
        "id",
        "headsign",
        "short_name",
        "direction_id",
        "block_id",
        "shape_id",
        "wheelchair_accessible",
        "route_type",
        "route_pattern_id",
        "bikes_allowed"
      ]
    )
  end
end
