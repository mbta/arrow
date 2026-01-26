defmodule Arrow.Trainsformer.Export do
  @moduledoc "schema for a Trainsformer export for the db"

  use Arrow.Schema
  import Ecto.Changeset

  alias Arrow.Disruptions.DisruptionV2
  alias Arrow.Trainsformer.Route
  alias Arrow.Trainsformer.Service

  typed_schema "trainsformer_exports" do
    field :s3_path, :string
    field :name, :string

    has_many :services, Service,
      foreign_key: :export_id,
      on_replace: :delete

    has_many :routes, Route, on_replace: :delete, foreign_key: :export_id
    belongs_to :disruption, DisruptionV2

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(export, attrs) do
    export
    |> cast(attrs, [:s3_path, :disruption_id, :name])
    |> cast_assoc(:services, with: &Service.changeset/2, required: true)
    |> cast_assoc(:routes, with: &Route.changeset/2, required: true)
    |> validate_required([:s3_path])
    |> assoc_constraint(:disruption)
  end
end
