defmodule Arrow.Hastus.ServiceDate do
  @moduledoc "schema for a HASTUS service date for the db"

  use Arrow.Schema
  import Ecto.Changeset

  typed_schema "hastus_service_dates" do
    field :start_date, :date
    field :end_date, :date
    belongs_to :service, Arrow.Hastus.Service, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(service_date, attrs) do
    service_date
    |> cast(attrs, [:start_date, :end_date, :service_id])
    |> validate_required([:start_date, :end_date])
    |> Arrow.Util.validate_start_date_before_end_date()
    |> assoc_constraint(:service)
  end

  @doc """
  Returns a set of days-of-week (as integers) covered by a service_date.
  """
  @spec day_of_weeks(t()) :: MapSet.t(1..7)
  def day_of_weeks(%__MODULE__{} = service_date) do
    service_date.start_date
    |> Date.range(service_date.end_date)
    |> Stream.take(7)
    |> MapSet.new(&Date.day_of_week/1)
  end
end
