defmodule Arrow.Hastus.DerivedLimit do
  @moduledoc "schema for a disruption limit derived from a HASTUS export"

  use Arrow.Schema
  import Ecto.Changeset

  alias Arrow.Gtfs.Stop
  alias Arrow.Hastus.Service

  typed_schema "hastus_derived_limits" do
    belongs_to :service, Service

    belongs_to :start_stop, Stop, type: :string
    belongs_to :end_stop, Stop, type: :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(hastus_limit, attrs) do
    hastus_limit
    |> cast(attrs, [
      :start_stop_id,
      :end_stop_id
    ])
    |> validate_required([
      :start_stop_id,
      :end_stop_id
    ])
    |> assoc_constraint(:service)
    |> assoc_constraint(:start_stop)
    |> assoc_constraint(:end_stop)
  end
end
