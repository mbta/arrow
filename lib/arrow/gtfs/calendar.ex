defmodule Arrow.Gtfs.Calendar do
  @moduledoc """
  Represents a row from calendar.txt.

  Changeset is intended for use only in CSV imports--
  table contents should be considered read-only otherwise.
  """
  use Arrow.Gtfs.Schema

  import Ecto.Changeset

  alias Arrow.Gtfs.Service

  @primary_key false

  @type t :: %__MODULE__{
          service: Service.t() | Ecto.Association.NotLoaded.t(),
          monday: boolean,
          tuesday: boolean,
          wednesday: boolean,
          thursday: boolean,
          friday: boolean,
          saturday: boolean,
          sunday: boolean,
          start_date: Date.t(),
          end_date: Date.t()
        }

  schema "gtfs_calendars" do
    belongs_to :service, Service, primary_key: true

    for day <- ~w[monday tuesday wednesday thursday friday saturday sunday]a do
      field day, :boolean
    end

    field :start_date, :date
    field :end_date, :date
  end

  def changeset(calendar, attrs) do
    attrs = values_to_iso8601_datestamp(attrs, ~w[start_date end_date])

    calendar
    |> cast(
      attrs,
      ~w[service_id monday tuesday wednesday thursday friday saturday sunday start_date end_date]a
    )
    |> validate_required(~w[service_id monday tuesday wednesday thursday friday saturday sunday start_date end_date]a)
    |> assoc_constraint(:service)
    |> validate_start_date_not_after_end_date()
  end

  defp validate_start_date_not_after_end_date(changeset) do
    start_date = fetch_field!(changeset, :start_date)
    end_date = fetch_field!(changeset, :end_date)

    if Date.compare(start_date, end_date) in [:lt, :eq] do
      changeset
    else
      add_error(changeset, :dates, "start date should not be after end date")
    end
  end

  @impl Arrow.Gtfs.Importable
  def filenames, do: ["calendar.txt"]
end
