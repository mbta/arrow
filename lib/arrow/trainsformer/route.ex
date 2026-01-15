defmodule Arrow.Trainsformer.Route do
  @moduledoc "schema for a Trainsformer export route"

  use Arrow.Schema
  import Ecto.Changeset

  typed_schema "trainsformer_export_routes" do
    belongs_to :export, Arrow.Trainsformer.Export, on_replace: :delete
    belongs_to :route, Arrow.Gtfs.Route, type: :string
  end

  @doc false
  def changeset(route, attrs) do
    route
    |> cast(attrs, [:route_id])
    |> validate_required([:route_id])
    |> assoc_constraint(:export)
    |> assoc_constraint(:route)
  end
end
