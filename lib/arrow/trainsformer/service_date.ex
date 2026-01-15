defmodule Arrow.Trainsformer.ServiceDate do
  @moduledoc "schema for a Trainsformer service date"

  use Arrow.Schema
  import Ecto.Changeset

  typed_schema "trainsformer_service_dates" do
    field :start_date, :date
    field :end_date, :date
    belongs_to :service, Arrow.Trainsformer.Service, on_replace: :delete
  end

  @doc false
  def changeset(service_date, attrs) do
    service_date
    |> cast(attrs, [:start_date, :end_date, :service_id])
    |> validate_required([:start_date, :end_date])
    |> assoc_constraint(:service)
  end
end
