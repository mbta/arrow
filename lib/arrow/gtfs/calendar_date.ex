defmodule Arrow.Gtfs.CalendarDate do
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

  schema "gtfs_calendar_dates" do
    belongs_to :service, Arrow.Gtfs.Service, primary_key: true
    field :date, :date, primary_key: true
    field :exception_type, Ecto.Enum, values: [added: 1, removed: 2]
    field :holiday_name, :string
  end

  def changeset(calendar_date, attrs) do
    attrs =
      attrs
      |> values_to_iso8601_datestamp(~w[date])
      |> values_to_int(~w[exception_type])

    calendar_date
    |> cast(attrs, ~w[service_id date exception_type holiday_name]a)
    |> validate_required(~w[service_id date exception_type]a)
    |> assoc_constraint(:service)
  end

  @impl Arrow.Gtfs.Importable
  def filenames, do: ["calendar_dates.txt"]
end
