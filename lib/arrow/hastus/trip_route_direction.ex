defmodule Arrow.Hastus.TripRouteDirection do
  @moduledoc "schema for the trip_route_directions entries"

  use Arrow.Schema

  import Ecto.Changeset

  typed_schema "hastus_trip_route_directions" do
    field :hastus_route_id, :string
    field :via_variant, :string
    field :avi_code, :string

    belongs_to :hastus_export, Arrow.Hastus.Export
    belongs_to :route, Arrow.Gtfs.Route, type: :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(trip_route_direction, attrs) do
    trip_route_direction
    |> cast(attrs, [:hastus_route_id, :via_variant, :avi_code, :route_id])
    |> assoc_constraint(:hastus_export)
    |> assoc_constraint(:route)
  end
end
