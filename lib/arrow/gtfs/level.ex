defmodule Arrow.Gtfs.Level do
  @moduledoc """
  Represents a row from levels.txt.

  Changeset is intended for use only in CSV imports--
  table contents should be considered read-only otherwise.
  """
  use Arrow.Gtfs.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: String.t(),
          index: String.t(),
          name: String.t() | nil
        }

  schema "gtfs_levels" do
    field :index, :float
    field :name, :string

    has_many :stop, Arrow.Gtfs.Stop
  end

  def changeset(level, attrs) do
    attrs = remove_table_prefix(attrs, "level")

    level
    |> cast(attrs, ~w[id index name]a)
    |> validate_required(~w[id index]a)
  end

  @impl Arrow.Gtfs.Importable
  def filename, do: "levels.txt"
end
