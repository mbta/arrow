defmodule Arrow.Hastus.ServiceDate do
  @moduledoc "schema for a HASTUS service date for the db"

  use Ecto.Schema
  import Ecto.Changeset

  alias Arrow.Hastus.Service

  @type t :: %__MODULE__{
          start_date: Date.t(),
          end_date: Date.t(),
          service: Service.t() | Ecto.Association.NotLoaded.t()
        }

  schema "hastus_service_dates" do
    field :start_date, :date
    field :end_date, :date
    belongs_to :service, Arrow.Hastus.Service

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(service_date, attrs) do
    service_date
    |> cast(attrs, [:start_date, :end_date, :service_id])
    |> validate_required([:start_date, :end_date])
    |> assoc_constraint(:service)
  end
end
