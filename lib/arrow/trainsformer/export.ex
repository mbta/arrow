defmodule Arrow.Trainsformer.Export do
  @moduledoc "schema for a Trainsformer export for the db"

  use Arrow.Schema
  import Ecto.Changeset

  alias Arrow.Disruptions.DisruptionV2

  typed_schema "trainsformer_exports" do
    field :s3_path, :string

    belongs_to :disruption, DisruptionV2
  end

  @doc false
  def changeset(export, attrs) do
    export
    |> cast(attrs, [:s3_path, :disruption_id])
    |> validate_required([:s3_path])
    |> assoc_constraint(:disruption)
  end
end
