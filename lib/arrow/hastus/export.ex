defmodule Arrow.Hastus.Export do
  @moduledoc "schema for a HASTUS export for the db"

  use Ecto.Schema

  import Ecto.Changeset

  alias Arrow.Disruptions.DisruptionV2
  alias Arrow.Gtfs.Line
  alias Arrow.Hastus.Service
  alias Arrow.Hastus.TripRouteDirection

  @type t :: %__MODULE__{
          s3_path: String.t(),
          services: list(Service) | Ecto.Association.NotLoaded.t(),
          line: Line.t() | Ecto.Association.NotLoaded.t(),
          disruption: DisruptionV2.t() | Ecto.Association.NotLoaded.t()
        }

  schema "hastus_exports" do
    field :s3_path, :string
    has_many :services, Arrow.Hastus.Service, on_replace: :delete, foreign_key: :export_id

    has_many :trip_route_directions, Arrow.Hastus.TripRouteDirection,
      on_delete: :delete_all,
      foreign_key: :hastus_export_id

    belongs_to :line, Arrow.Gtfs.Line, type: :string
    belongs_to :disruption, Arrow.Disruptions.DisruptionV2

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(export, attrs) do
    export
    |> cast(attrs, [:s3_path, :line_id, :disruption_id])
    |> validate_required([:s3_path])
    |> cast_assoc(:services, with: &Service.changeset/2, required: true)
    |> cast_assoc(:trip_route_directions, with: &TripRouteDirection.changeset/2)
    |> assoc_constraint(:line)
    |> assoc_constraint(:disruption)
  end
end
