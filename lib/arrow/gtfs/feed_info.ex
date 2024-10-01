defmodule Arrow.Gtfs.FeedInfo do
  @moduledoc """
  Represents a row from feed_info.txt.

  Changeset is intended for use only in CSV imports--
  table contents should be considered read-only otherwise.
  """
  use Arrow.Gtfs.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: String.t(),
          publisher_name: String.t(),
          publisher_url: String.t(),
          lang: String.t(),
          start_date: Date.t(),
          end_date: Date.t(),
          version: String.t(),
          contact_email: String.t()
        }

  schema "gtfs_feed_info" do
    field :publisher_name, :string
    field :publisher_url, :string
    field :lang, :string
    field :start_date, Arrow.Gtfs.Types.Date
    field :end_date, Arrow.Gtfs.Types.Date
    field :version, :string
    field :contact_email, :string
  end

  def changeset(feed_info, attrs) do
    attrs = remove_table_prefix(attrs, "feed")

    feed_info
    |> cast(
      attrs,
      ~w[id publisher_name publisher_url lang start_date end_date version contact_email]a
    )
    |> validate_required(
      ~w[id publisher_name publisher_url lang start_date end_date version contact_email]a
    )
    |> validate_start_date_before_end_date()
  end

  defp validate_start_date_before_end_date(changeset) do
    start_date = fetch_field!(changeset, :start_date)
    end_date = fetch_field!(changeset, :end_date)

    if Date.compare(start_date, end_date) == :lt do
      changeset
    else
      add_error(changeset, :dates, "start date should be before end date")
    end
  end

  @impl Arrow.Gtfs.Importable
  def filenames, do: ["feed_info.txt"]
end
