defmodule Arrow.Gtfs.RoutePattern do
  @moduledoc """
  Represents a row from route_patterns.txt.

  Changeset is intended for use only in CSV imports--
  table contents should be considered read-only otherwise.
  """
  use Arrow.Gtfs.Schema
  import Ecto.Changeset

  @typicality_values Enum.with_index(
                       ~w[not_defined typical deviation atypical diversion typical_but_unscheduled]a
                     )

  @canonicality_values Enum.with_index(
                         ~w[no_canonical_patterns_defined_for_route canonical not_canonical]a
                       )

  typed_schema "gtfs_route_patterns" do
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
    field :typicality, Ecto.Enum, values: @typicality_values
    field :sort_order, :integer

    # The Trip that exemplifies this RoutePattern.
    belongs_to :representative_trip, Arrow.Gtfs.Trip
    # All the Trips that use this RoutePattern.
    has_many :trips, Arrow.Gtfs.Trip
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
    |> validate_required(
      ~w[id route_id direction_id name typicality sort_order representative_trip_id canonical]a
    )
    |> assoc_constraint(:route)
    |> assoc_constraint(:representative_trip)
  end

  @impl Arrow.Gtfs.Importable
  def filenames, do: ["route_patterns.txt"]
end
