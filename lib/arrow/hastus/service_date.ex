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

  embedded_schema do
    field :start_date, :date
    field :end_date, :date
    belongs_to :service, Arrow.Hastus.Service
  end

  @doc false
  def changeset(date, attrs) do
    date
    |> cast(attrs, [:start_date, :end_date])
    |> assoc_constraint(:service)
  end
end
