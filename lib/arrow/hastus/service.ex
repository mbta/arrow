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
    field :import?, :boolean, source: :should_import, default: true
    belongs_to :start_stop, Arrow.Gtfs.Stop, type: :string
    belongs_to :end_stop, Arrow.Gtfs.Stop, type: :string

    has_many :service_dates, Arrow.Hastus.ServiceDate,
      on_replace: :delete,
      foreign_key: :service_id

    belongs_to :export, Arrow.Hastus.Export

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(service, attrs) do
    service
    |> cast(attrs, [:name, :export_id, :import?, :start_stop_id, :end_stop_id])
    |> validate_required([:name])
    |> cast_assoc(:service_dates, with: &ServiceDate.changeset/2)
    |> assoc_constraint(:export)
    |> foreign_key_constraint(:start_stop_id, name: :hastus_services_start_stop_id_fkey)
    |> foreign_key_constraint(:end_stop_id, name: :hastus_services_end_stop_id_fkey)
  end
end
