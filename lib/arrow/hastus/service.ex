defmodule Arrow.Hastus.Service do
  @moduledoc "schema for a HASTUS service for the db"

  use Ecto.Schema
  import Ecto.Changeset

  alias Arrow.Hastus.{Export, ServiceDate}

  @type t :: %__MODULE__{
          name: String.t(),
          service_dates: list(ServiceDate) | Ecto.Association.NotLoaded.t(),
          import?: boolean(),
          export: Export.t() | Ecto.Association.NotLoaded.t()
        }

  schema "hastus_services" do
    field :name, :string
    field :import?, :boolean, virtual: true
    has_many :service_dates, Arrow.Hastus.ServiceDate
    belongs_to :export, Arrow.Hastus.Service

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(service, attrs) do
    service
    |> cast(attrs, [:name, :export_id])
    |> validate_required([:name])
    |> cast_assoc(:service_dates, with: &ServiceDate.changeset/2)
    |> assoc_constraint(:export)
  end
end
