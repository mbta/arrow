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
    belongs_to :service, Arrow.Hastus.Service, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(service_date, attrs) do
    service_date
    |> cast(attrs, [:start_date, :end_date, :service_id])
    |> validate_required([:start_date, :end_date])
    |> validate_start_date_before_end_date()
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

  @spec validate_start_date_before_end_date(Ecto.Changeset.t(t())) :: Ecto.Changeset.t(t())
  defp validate_start_date_before_end_date(changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)

    cond do
      is_nil(start_date) or is_nil(end_date) ->
        changeset

      Date.compare(start_date, end_date) == :gt ->
        add_error(changeset, :start_date, "start date must be less than or equal to end date")

      true ->
        changeset
    end
  end
end
