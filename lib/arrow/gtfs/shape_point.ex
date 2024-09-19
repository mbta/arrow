defmodule Arrow.Gtfs.ShapePoint do
  use Arrow.Gtfs.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          shape: Arrow.Gtfs.Shape.t() | Ecto.Association.NotLoaded.t(),
          sequence: integer,
          lat: float,
          lon: float,
          dist_traveled: float | nil
        }

  @primary_key false

  schema "gtfs_shape_points" do
    belongs_to :shape, Arrow.Gtfs.Shape, primary_key: true
    field :sequence, :integer, primary_key: true
    field :lat, :float
    field :lon, :float
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
end
