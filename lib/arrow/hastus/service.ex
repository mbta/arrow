defmodule Arrow.Hastus.Service do
  use Ecto.Schema
  import Ecto.Changeset

  alias Arrow.Hastus.Export

  @type t :: %__MODULE__{
          service_id: String.t(),
          start_date: Date.t(),
          end_date: Date.t(),
          import?: boolean(),
          export: Export.t() | Ecto.Association.NotLoaded.t()
        }

  embedded_schema do
    field :service_id, :string
    field :start_date, :date
    field :end_date, :date
    field :import?, :boolean, virtual: true
    belongs_to :export, Arrow.Hastus.Service
  end

  @doc false
  def changeset(service, attrs) do
    cast(service, attrs, [
      :service_id,
      :start_date,
      :end_date,
      :export_id
    ])
  end
end
