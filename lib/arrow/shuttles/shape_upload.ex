defmodule Arrow.Shuttles.ShapeUpload do
  @moduledoc "schema for shuttle shapes as an embedded schema"
  use Arrow.Schema
  import Ecto.Changeset

  typed_embedded_schema do
    field :name, :string
    field :coordinates, {:array, :string}
  end

  @doc false
  def changeset(shape, attrs) do
    shape
    |> cast(attrs, [:name, :coordinates], empty_values: ["-S"] ++ empty_values())
    |> validate_required([:name, :coordinates])
    |> validate_length(:coordinates, min: 2)
  end
end
