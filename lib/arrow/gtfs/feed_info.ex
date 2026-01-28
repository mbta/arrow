defmodule Arrow.Gtfs.FeedInfo do
  @moduledoc """
  Represents a row from feed_info.txt.

  Changeset is intended for use only in CSV imports--
  table contents should be considered read-only otherwise.
  """
  use Arrow.Gtfs.Schema
  import Ecto.Changeset

  typed_schema "gtfs_feed_info" do
    field :publisher_name, :string
    field :publisher_url, :string
    field :lang, :string
    field :start_date, :date
    field :end_date, :date
    field :version, :string
    field :contact_email, :string
  end

  def changeset(feed_info, attrs) do
    attrs =
      attrs
      |> remove_table_prefix("feed")
      |> values_to_iso8601_datestamp(~w[start_date end_date])

    feed_info
    |> cast(
      attrs,
      ~w[id publisher_name publisher_url lang start_date end_date version contact_email]a
    )
    |> validate_required(
      ~w[id publisher_name publisher_url lang start_date end_date version contact_email]a
    )
    |> Arrow.Util.validate_start_date_before_end_date()
  end

  @impl Arrow.Gtfs.Importable
  def filenames, do: ["feed_info.txt"]
end
