defmodule Arrow.Gtfs.RoutePattern do
  use Arrow.Gtfs.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: String.t(),
          route: Arrow.Gtfs.Route.t() | Ecto.Association.NotLoaded.t(),
          direction_id: 0 | 1,
          directions: list(Arrow.Gtfs.Direction.t()) | Ecto.Association.NotLoaded.t(),
          name: String.t(),
          time_desc: String.t() | nil,
          typicality: atom,
          sort_order: integer,
          # The Trip that exemplifies this RoutePattern.
          representative_trip: Arrow.Gtfs.Trip.t() | Ecto.Association.NotLoaded.t(),
          # All the Trips that use this RoutePattern.
          trips: list(Arrow.Gtfs.Trip.t()) | Ecto.Association.NotLoaded.t(),
          canonical: atom
        }

  @typicality_values Enum.with_index(
                       ~w[not_defined typical deviation atypical diversion typical_but_unscheduled]a
                     )

  @canonicality_values Enum.with_index(
                         ~w[no_canonical_patterns_defined_for_route canonical not_canonical]a
                       )

  schema "gtfs_route_patterns" do
    belongs_to :route, Arrow.Gtfs.Route, type: :string
    field :direction_id, :integer
    # I couldn't find a way to directly associate the specific Direction
    # here--composite FK relations aren't supported.
    #
    # So as a workaround, we have all the Directions of the associated Route and
    # can manually look up the one that has this RoutePattern's direction_id.
    has_many :directions, through: [:route, :directions]
    field :name, :string
    field :time_desc, :string
    field :typicality, Arrow.Gtfs.Types.Enum, values: @typicality_values
    field :sort_order, :integer
    belongs_to :representative_trip, Arrow.Gtfs.Trip
    has_many :trips, Arrow.Gtfs.Trip
    field :canonical, Arrow.Gtfs.Types.Enum, values: @canonicality_values
  end

  def changeset(route_pattern, attrs) do
    attrs =
      attrs
      |> remove_table_prefix("route_pattern")
      |> Map.pop("canonical_route_pattern")
      |> then(fn
        {nil, attrs} -> attrs
        {canonical, attrs} -> Map.put(attrs, "canonical", canonical)
      end)

    route_pattern
    |> cast(
      attrs,
      ~w[id route_id direction_id name time_desc typicality sort_order representative_trip_id canonical]a
    )
    |> validate_required(
      ~w[id route_id direction_id name typicality sort_order representative_trip_id canonical]a
    )
    |> assoc_constraint(:route)

    # No assoc_constraint for representative_trip_id because the relationship
    # is circular and we populate this table before gtfs_trips.
    # (DB has a deferred FK constraint for representative_trip_id, though)
  end
end
