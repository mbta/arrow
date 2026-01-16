defmodule Arrow.Gtfs.ShapePoint do
  @moduledoc """
  Represents a row from shapes.txt.

  ShapePoints are grouped under Shapes, by their shape_id field.

  Changeset is intended for use only in CSV imports--
  table contents should be considered read-only otherwise.
  """
  use Arrow.Gtfs.Schema
  import Ecto.Changeset

  @primary_key false

  typed_schema "gtfs_shape_points" do
    belongs_to :shape, Arrow.Gtfs.Shape, primary_key: true
    field :lat, :float
    field :lon, :float
    field :sequence, :integer, primary_key: true
    field :dist_traveled, :float
  end

  def changeset(shape_point, attrs) do
    attrs =
      attrs
      |> remove_table_prefix("shape_pt")
      |> remove_table_prefix("shape", except: "shape_id")

    shape_point
    |> cast(attrs, ~w[shape_id sequence lat lon dist_traveled]a)
    |> validate_required(~w[shape_id sequence lat lon]a)
    |> assoc_constraint(:shape)
  end

  @impl Arrow.Gtfs.Importable
  def filenames, do: ["shapes.txt"]

  @impl Arrow.Gtfs.Importable
  def import(unzip) do
    Arrow.Gtfs.Importable.import_using_copy(
      __MODULE__,
      unzip,
      header_mappings: %{
        "shape_pt_lat" => "lat",
        "shape_pt_lon" => "lon",
        "shape_pt_sequence" => "sequence",
        "shape_dist_traveled" => "dist_traveled"
      }
    )
  end
end
