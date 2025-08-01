defmodule Arrow.Hastus.Export do
  @moduledoc "schema for a HASTUS export for the db"

  use Ecto.Schema

  import Ecto.Changeset

  alias Arrow.Disruptions.DisruptionV2
  alias Arrow.Gtfs.Line
  alias Arrow.Hastus.Service
  alias Arrow.Hastus.TripRouteDirection
  alias Ecto.Association.NotLoaded

  @type t :: %__MODULE__{
          s3_path: String.t(),
          services: list(Service.t()) | NotLoaded.t(),
          trip_route_directions: list(TripRouteDirection.t()) | NotLoaded.t(),
          line: Line.t() | NotLoaded.t(),
          disruption: DisruptionV2.t() | NotLoaded.t()
        }

  schema "hastus_exports" do
    field :s3_path, :string
    has_many :services, Service, on_replace: :delete, foreign_key: :export_id

    has_many :trip_route_directions, TripRouteDirection,
      on_delete: :delete_all,
      foreign_key: :hastus_export_id

    belongs_to :line, Line, type: :string
    belongs_to :disruption, DisruptionV2

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

  @doc """
  Returns true if `export` has any derived limits.
  """
  @spec has_derived_limits?(t()) :: boolean
  def has_derived_limits?(%__MODULE__{} = export) do
    export = Arrow.Repo.preload(export, [:services])

    Enum.any?(export.services, &Service.has_derived_limits?/1)
  end
end
