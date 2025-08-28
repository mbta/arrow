defmodule Arrow.Gtfs.Line do
  @moduledoc """
  Represents a row from lines.txt.

  Changeset is intended for use only in CSV imports--
  table contents should be considered read-only otherwise.
  """
  use Arrow.Gtfs.Schema
  import Ecto.Changeset

  typed_schema "gtfs_lines" do
    field :short_name, :string
    field :long_name, :string
    field :desc, :string
    field :url, :string
    field :color, :string
    field :text_color, :string
    field :sort_order, :integer

    has_many :routes, Arrow.Gtfs.Route
  end

  def changeset(line, attrs) do
    attrs = remove_table_prefix(attrs, "line")

    line
    |> cast(attrs, ~w[id short_name long_name desc url color text_color sort_order]a)
    |> validate_required(~w[id long_name color text_color sort_order]a)
  end

  @impl Arrow.Gtfs.Importable
  def filenames, do: ["lines.txt"]
end
