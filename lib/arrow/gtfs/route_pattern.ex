defmodule Arrow.Gtfs.RoutePattern do
  @moduledoc """
  Represents a row from route_patterns.txt.

  Changeset is intended for use only in CSV imports--
  table contents should be considered read-only otherwise.
  """
  use Arrow.Gtfs.Schema

  import Ecto.Changeset

  alias Arrow.Gtfs.Route
  alias Arrow.Gtfs.Trip
  alias Ecto.Association.NotLoaded

  @type t :: %__MODULE__{
          id: String.t(),
          route: Route.t() | NotLoaded.t(),
          direction_id: 0 | 1,
          directions: list(Arrow.Gtfs.Direction.t()) | NotLoaded.t(),
          name: String.t(),
          time_desc: String.t() | nil,
          typicality: atom,
          sort_order: integer,
          # The Trip that exemplifies this RoutePattern.
          representative_trip: Trip.t() | NotLoaded.t(),
          # All the Trips that use this RoutePattern.
          trips: list(Trip.t()) | NotLoaded.t(),
          canonical: atom
        }

  @typicality_values Enum.with_index(~w[not_defined typical deviation atypical diversion typical_but_unscheduled]a)

  @canonicality_values Enum.with_index(~w[no_canonical_patterns_defined_for_route canonical not_canonical]a)

  schema "gtfs_route_patterns" do
    belongs_to :route, Route, type: :string
    field :direction_id, :integer
    # I couldn't find a way to directly associate the specific Direction
    # here--composite FK relations aren't supported.
    #
    # So as a workaround, we have all the Directions of the associated Route and
    # can manually look up the one that has this RoutePattern's direction_id.
    has_many :directions, through: [:route, :directions]
    field :name, :string
    field :time_desc, :string
    field :typicality, Ecto.Enum, values: @typicality_values
    field :sort_order, :integer
    belongs_to :representative_trip, Trip
    has_many :trips, Trip
    field :canonical, Ecto.Enum, values: @canonicality_values
  end

  def changeset(route_pattern, attrs) do
    attrs =
      attrs
      |> remove_table_prefix("route_pattern")
      |> rename_key("canonical_route_pattern", "canonical")
      |> values_to_int(~w[typicality canonical])

    route_pattern
    |> cast(
      attrs,
      ~w[id route_id direction_id name time_desc typicality sort_order representative_trip_id canonical]a
    )
    |> validate_required(~w[id route_id direction_id name typicality sort_order representative_trip_id canonical]a)
    |> assoc_constraint(:route)
    |> assoc_constraint(:representative_trip)
  end

  @impl Arrow.Gtfs.Importable
  def filenames, do: ["route_patterns.txt"]
end
