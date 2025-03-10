defmodule Arrow.Gtfs.Shape do
  @moduledoc """
  Represents a group of rows from shapes.txt that all share a shape_id.

  A Shape contains many ShapePoints.

  Changeset is intended for use only in CSV imports--
  table contents should be considered read-only otherwise.
  """
  use Arrow.Gtfs.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: String.t(),
          points: list(Arrow.Gtfs.ShapePoint.t()) | Ecto.Association.NotLoaded.t(),
          trips: list(Arrow.Gtfs.Trip.t()) | Ecto.Association.NotLoaded.t()
        }

  schema "gtfs_shapes" do
    has_many :points, Arrow.Gtfs.ShapePoint
    has_many :trips, Arrow.Gtfs.Trip
  end

  # This shape's points should be put in a separate list and imported
  # after this table is populated, so that FKs can be validated.
  def changeset(shape, attrs) do
    attrs = remove_table_prefix(attrs, "shape")

    shape
    |> cast(attrs, ~w[id]a)
    |> validate_required(~w[id]a)
  end

  @impl Arrow.Gtfs.Importable
  def filenames, do: ["shapes.txt"]

  @impl Arrow.Gtfs.Importable
  def import(unzip) do
    [filename] = filenames()

    unzip
    |> Arrow.Gtfs.ImportHelper.stream_csv_rows(filename)
    |> Stream.uniq_by(& &1["shape_id"])
    |> Arrow.Gtfs.Importable.cast_and_insert(__MODULE__)
  end
end
