defmodule Arrow.Gtfs.Checkpoint do
  @moduledoc """
  Represents a row from checkpoints.txt.

  Changeset is intended for use only in CSV imports--
  table contents should be considered read-only otherwise.
  """
  use Arrow.Gtfs.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t()
        }

  schema "gtfs_checkpoints" do
    field :name, :string
    has_many :stop_times, Arrow.Gtfs.StopTime
  end

  def changeset(checkpoint, attrs) do
    attrs = remove_table_prefix(attrs, "checkpoint")

    checkpoint
    |> cast(attrs, ~w[id name]a)
    |> validate_required(~w[id name]a)
  end

  @impl Arrow.Gtfs.Importable
  def filename, do: "checkpoints.txt"
end
