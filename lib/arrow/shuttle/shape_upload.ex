defmodule Arrow.Shuttle.ShapeUpload do
  @moduledoc "schema for shuttle shapes as an embedded schema"
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          name: String.t(),
          coordinates: list(String.t())
        }

  embedded_schema do
    field :name, :string
    field :coordinates, {:array, :string}
  end

  @doc false
  def changeset(shape, attrs) do
    shape
    |> cast(attrs, [:name, :coordinates])
    |> validate_required([:name, :coordinates])
    |> validate_length(:coordinates, min: 2)
  end
end
