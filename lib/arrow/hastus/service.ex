defmodule Arrow.Hastus.Service do
  use Ecto.Schema
  import Ecto.Changeset

  alias Arrow.Hastus.{Export, ServiceDate}

  @type t :: %__MODULE__{
          service_id: String.t(),
          service_dates: list(ServiceDate) | Ecto.Association.NotLoaded.t(),
          import?: boolean(),
          export: Export.t() | Ecto.Association.NotLoaded.t()
        }

  embedded_schema do
    field :service_id, :string
    field :import?, :boolean, virtual: true
    has_many :service_dates, Arrow.Hastus.ServiceDate
    belongs_to :export, Arrow.Hastus.Service
  end

  @doc false
  def changeset(service, attrs) do
    service
    |> cast(attrs, [:service_id])
    |> cast_assoc(:service_dates, with: &ServiceDate.changeset/2)
    |> assoc_constraint(:export)
  end
end
