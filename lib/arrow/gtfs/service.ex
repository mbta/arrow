defmodule Arrow.Gtfs.Service do
  @moduledoc """
  Ecto schema for a row in calendar.txt
  """

  use Arrow.Gtfs.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: String.t(),
          monday: boolean,
          tuesday: boolean,
          wednesday: boolean,
          thursday: boolean,
          friday: boolean,
          saturday: boolean,
          sunday: boolean,
          start_date: Date.t(),
          end_date: Date.t(),
          dates: list(Arrow.Gtfs.ServiceDate.t()) | Ecto.Association.NotLoaded.t()
        }

  schema "gtfs_services" do
    # Should these be combined into one list or map field?
    # E.g. %{monday: true, tuesday: false, ...} or [true, false, ...]
    for day <- ~w[monday tuesday wednesday thursday friday saturday sunday]a do
      field day, :boolean
    end

    field :start_date, Arrow.Gtfs.Types.Date
    field :end_date, Arrow.Gtfs.Types.Date

    has_many :dates, Arrow.Gtfs.ServiceDate
    has_many :trips, Arrow.Gtfs.Trip
  end

  def changeset(service, attrs) do
    attrs = remove_table_prefix(attrs, "service")

    service
    |> cast(
      attrs,
      ~w[id monday tuesday wednesday thursday friday saturday sunday start_date end_date]a
    )
    |> validate_required(
      ~w[id monday tuesday wednesday thursday friday saturday sunday start_date end_date]a
    )
    |> validate_start_date_before_end_date()
  end

  defp validate_start_date_before_end_date(changeset) do
    start_date = fetch_field!(changeset, :start_date)
    end_date = fetch_field!(changeset, :end_date)

    if Date.compare(start_date, end_date) in [:lt, :eq] do
      changeset
    else
      add_error(changeset, :dates, "start date should not be after end date")
    end
  end

  @impl Arrow.Gtfs.Importable
  def filename, do: "calendar.txt"
end
