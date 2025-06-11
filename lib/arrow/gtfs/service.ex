defmodule Arrow.Gtfs.Service do
  @moduledoc """
  Represents all calendar data related to a service_id,
  which may exist in one or both of calendar.txt or calendar_dates.txt.

  Changeset is intended for use only in CSV imports--
  table contents should be considered read-only otherwise.
  """
  use Arrow.Gtfs.Schema

  import Ecto.Changeset

  alias Arrow.Gtfs.Calendar
  alias Arrow.Gtfs.CalendarDate
  alias Arrow.Gtfs.Importable
  alias Ecto.Association.NotLoaded

  @type t :: %__MODULE__{
          calendar: Calendar.t() | NotLoaded.t(),
          calendar_dates: list(CalendarDate.t()) | NotLoaded.t()
        }

  schema "gtfs_services" do
    has_one :calendar, Calendar
    has_many :calendar_dates, CalendarDate

    has_many :trips, Arrow.Gtfs.Trip
  end

  def changeset(service, attrs) do
    service
    |> cast(attrs, [:id])
    |> validate_required(~w[id]a)
  end

  @impl Importable
  def filenames, do: ["calendar.txt", "calendar_dates.txt"]

  @impl Importable
  def import(unzip) do
    # This table's IDs are the union of those found in
    # calendar.txt and calendar_dates.txt.
    service_rows =
      filenames()
      |> Enum.map(&Arrow.Gtfs.ImportHelper.stream_csv_rows(unzip, &1))
      |> Stream.concat()
      |> Stream.uniq_by(& &1["service_id"])
      |> Stream.map(&%{"id" => Map.fetch!(&1, "service_id")})

    Importable.cast_and_insert(service_rows, __MODULE__)
  end
end
