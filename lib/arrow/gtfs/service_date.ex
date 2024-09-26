defmodule Arrow.Gtfs.ServiceDate do
  @moduledoc """
  Represents a row from calendar_dates.txt.

  Changeset is intended for use only in CSV imports--
  table contents should be considered read-only otherwise.
  """
  use Arrow.Gtfs.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          service: Arrow.Gtfs.Service.t() | Ecto.Association.NotLoaded.t(),
          date: Date.t(),
          exception_type: atom,
          holiday_name: String.t() | nil
        }

  @primary_key false

  schema "gtfs_service_dates" do
    belongs_to :service, Arrow.Gtfs.Service, primary_key: true
    field :date, Arrow.Gtfs.Types.Date, primary_key: true
    field :exception_type, Arrow.Gtfs.Types.Enum, values: [added: 1, removed: 2]
    field :holiday_name, :string
  end

  def changeset(service_date, attrs) do
    service_date
    |> cast(attrs, ~w[service_id date exception_type holiday_name]a)
    |> validate_required(~w[service_id date exception_type]a)
    |> assoc_constraint(:service)

    # |> validate_date_within_service_interval()
  end

  # This validation does not hold for all rows of calendar_dates.txt,
  # e.g. the one for service_id "RTL32024-hmo34017-Sunday-01"
  # which has date 2024-06-16 but whose service has date range
  # 2024-07-07 to 2024-08-18.
  # So, this validation is skipped for now.
  defp validate_date_within_service_interval(changeset) do
    # For some reason `get_assoc` didn't work here, I'm not sure why.
    # service = get_assoc(changeset, :service, :struct)

    service_id = fetch_field!(changeset, :service_id)
    service = Arrow.Repo.get(Arrow.Gtfs.Service, service_id)
    date = fetch_field!(changeset, :date)

    if Date.compare(date, service.start_date) in [:gt, :eq] and
         Date.compare(date, service.end_date) in [:lt, :eq] do
      changeset
    else
      add_error(
        changeset,
        :date,
        "date must be within the start and end dates of the associated service"
      )
    end
  end

  @impl Arrow.Gtfs.Importable
  def filename, do: "calendar_dates.txt"
end
