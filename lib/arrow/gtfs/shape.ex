defmodule Arrow.Gtfs.Shape do
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
end
