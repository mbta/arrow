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

    belongs_to :export, Export, on_replace: :delete, foreign_key: :export_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(service, attrs) do
    service
    |> cast(attrs, [:name, :export_id])
    |> cast_assoc(:service_dates,
      with: &ServiceDate.changeset/2,
      sort_param: :service_dates_sort,
      drop_param: :service_dates_drop
    )
    |> validate_required([:name])
    |> assoc_constraint(:export)
  end
end
