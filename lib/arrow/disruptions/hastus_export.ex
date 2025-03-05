defmodule Arrow.Disruptions.HastusExport do
  use Ecto.Schema

  import Ecto.Changeset

  alias Arrow.Disruptions.DisruptionV2
  alias Arrow.Repo.MapForForm

  @type t :: %__MODULE__{
          source_export_data: map(),
          source_export_filename: String.t(),
          disruption: DisruptionV2.t() | Ecto.Association.NotLoaded.t()
        }

  schema "hastus_export" do
    field :source_export_data, MapForForm
    field :source_export_filename, :string
    belongs_to :disruption, DisruptionV2

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(hastus_export, attrs) do
    hastus_export
    |> cast(attrs, [
      :source_export_data,
      :source_export_filename,
      :disruption_id
    ])
    |> assoc_constraint(:disruption)
  end
end
