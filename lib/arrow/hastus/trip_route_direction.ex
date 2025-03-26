defmodule Arrow.Hastus.TripRouteDirection do
  @moduledoc "schema for the trip_route_directions entries"

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{
          hastus_route_id: String.t(),
          via_variant: String.t(),
          avi_code: String.t()
        }

  schema "hastus_trip_route_directions" do
    field :hastus_route_id, :string
    field :via_variant, :string
    field :avi_code, :string

    belongs_to :hastus_export, Arrow.Hastus.Export
    belongs_to :route, Arrow.Gtfs.Route

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(trip_route_direction, attrs) do
    trip_route_direction
    |> cast(attrs, [:hastus_route_id, :via_variant, :avi_code])
    |> assoc_constraint(:hastus_export)
    |> assoc_constraint(:route)
  end
end
