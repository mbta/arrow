defmodule Arrow.Gtfs.Service do
  @moduledoc """
  Represents all calendar data related to a service_id,
  which may exist in one or both of calendar.txt or calendar_dates.txt.

  Changeset is intended for use only in CSV imports--
  table contents should be considered read-only otherwise.
  """
  use Arrow.Gtfs.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          calendar: Arrow.Gtfs.Calendar.t() | Ecto.Association.NotLoaded.t(),
          calendar_dates: list(Arrow.Gtfs.CalendarDate.t()) | Ecto.Association.NotLoaded.t()
        }

  schema "gtfs_services" do
    has_one :calendar, Arrow.Gtfs.Calendar
    has_many :calendar_dates, Arrow.Gtfs.CalendarDate

    has_many :trips, Arrow.Gtfs.Trip
  end

  def changeset(service, attrs) do
    cast(service, attrs, [:id])
  end

  @impl Arrow.Gtfs.Importable
  def filenames, do: ["calendar.txt", "calendar_dates.txt"]

  @impl Arrow.Gtfs.Importable
  def import(unzip) do
    # This table's IDs are the union of those found in
    # calendar.txt and calendar_dates.txt.
    service_rows =
      filenames()
      |> Enum.map(&Arrow.Gtfs.ImportHelper.stream_csv_rows(unzip, &1))
      |> Stream.concat()
      |> Stream.uniq_by(& &1["service_id"])
      |> Stream.map(&%{"id" => Map.fetch!(&1, "service_id")})

    Arrow.Gtfs.Importable.cast_and_insert(service_rows, __MODULE__)
  end
end
