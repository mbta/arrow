defmodule Arrow.Trainsformer.Service do
  @moduledoc "schema for a Trainsformer service"
  alias Arrow.Trainsformer.Export
  alias Arrow.Trainsformer.ServiceDate

  use Arrow.Schema
  import Ecto.Changeset

  typed_schema "trainsformer_services" do
    field :name, :string
    # field :import?, :boolean, source: :should_import, default: true

    has_many :service_dates, ServiceDate,
      on_replace: :delete,
      foreign_key: :service_id

    belongs_to :export, Export

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
