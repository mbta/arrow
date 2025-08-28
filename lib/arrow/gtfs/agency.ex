defmodule Arrow.Gtfs.Agency do
  @moduledoc """
  Represents a row from agency.txt.

  Changeset is intended for use only in CSV imports--
  table contents should be considered read-only otherwise.
  """
  use Arrow.Gtfs.Schema
  import Ecto.Changeset

  typed_schema "gtfs_agencies" do
    field :name, :string
    field :url, :string
    field :timezone, :string
    field :lang, :string
    field :phone, :string

    has_many :routes, Arrow.Gtfs.Route
  end

  def changeset(agency, attrs) do
    attrs = remove_table_prefix(attrs, "agency")

    agency
    |> cast(attrs, ~w[id name url timezone lang phone]a)
    |> validate_required(~w[id name url timezone]a)
  end

  @impl Arrow.Gtfs.Importable
  def filenames, do: ["agency.txt"]
end
