defmodule Arrow.Gtfs.Shape do
  @moduledoc """
  Represents a group of rows from shapes.txt that all share a shape_id.

  A Shape contains many ShapePoints.

  Changeset is intended for use only in CSV imports--
  table contents should be considered read-only otherwise.
  """
  use Arrow.Gtfs.Schema

  import Ecto.Changeset

  alias Arrow.Gtfs.Importable
  alias Arrow.Gtfs.ShapePoint
  alias Arrow.Gtfs.Trip
  alias Ecto.Association.NotLoaded

  @type t :: %__MODULE__{
          id: String.t(),
          points: list(ShapePoint.t()) | NotLoaded.t(),
          trips: list(Trip.t()) | NotLoaded.t()
        }

  schema "gtfs_shapes" do
    has_many :points, ShapePoint
    has_many :trips, Trip
  end

  # This shape's points should be put in a separate list and imported
  # after this table is populated, so that FKs can be validated.
  def changeset(shape, attrs) do
    attrs = remove_table_prefix(attrs, "shape")

    shape
    |> cast(attrs, ~w[id]a)
    |> validate_required(~w[id]a)
  end

  @impl Importable
  def filenames, do: ["shapes.txt"]

  @impl Importable
  def import(unzip) do
    [filename] = filenames()

    unzip
    |> Arrow.Gtfs.ImportHelper.stream_csv_rows(filename)
    |> Stream.uniq_by(& &1["shape_id"])
    |> Importable.cast_and_insert(__MODULE__)
  end
end
