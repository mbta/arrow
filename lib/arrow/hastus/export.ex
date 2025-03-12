defmodule Arrow.Hastus.Export do
  @moduledoc "schema for a HASTUS export for the db"

  use Ecto.Schema

  import Ecto.Changeset

  alias Arrow.Gtfs.Line
  alias Arrow.Hastus.Service

  @type t :: %__MODULE__{
          source_export_filename: String.t(),
          services: list(Service) | Ecto.Association.NotLoaded.t(),
          line: Line.t() | Ecto.Association.NotLoaded.t()
        }

  schema "hastus_export" do
    field :source_export_filename, :string
    has_many :services, Arrow.Hastus.Service
    belongs_to :line, Arrow.Gtfs.Line
  end

  @doc false
  def changeset(hastus_export, attrs) do
    hastus_export
    |> cast(attrs, [:source_export_filename])
    |> cast_assoc(:services, with: &Service.changeset/2)
  end
end
