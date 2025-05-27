defmodule Arrow.Hastus.DerivedLimit do
  @moduledoc "schema for a disruption limit derived from a HASTUS export"

  use Ecto.Schema
  import Ecto.Changeset

  alias Arrow.Gtfs.Stop
  alias Arrow.Hastus.Export

  @type t :: %__MODULE__{
          id: integer,
          export: Export.t() | Ecto.Association.NotLoaded.t(),
          export_id: integer,
          service_name: String.t(),
          start_stop: Stop.t() | Ecto.Association.NotLoaded.t(),
          start_stop_id: String.t(),
          end_stop: Stop.t() | Ecto.Association.NotLoaded.t(),
          end_stop_id: String.t(),
          start_date: Date.t(),
          end_date: Date.t()
        }

  schema "hastus_derived_limits" do
    belongs_to :export, Arrow.Hastus.Export
    field :service_name, :string

    belongs_to :start_stop, Arrow.Gtfs.Stop, type: :string
    belongs_to :end_stop, Arrow.Gtfs.Stop, type: :string
    field :start_date, :date
    field :end_date, :date

    # Needed?
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(hastus_limit, attrs) do
    hastus_limit
    |> cast(attrs, [
      :service_name,
      :start_stop_id,
      :end_stop_id,
      :start_date,
      :end_date
    ])
    |> validate_required([
      :service_name,
      :start_stop_id,
      :end_stop_id,
      :start_date,
      :end_date
    ])
    |> assoc_constraint(:export)
    |> assoc_constraint(:start_stop)
    |> assoc_constraint(:end_stop)
  end
end
