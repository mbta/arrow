defmodule Arrow.Shuttle.Shape do
  use Ecto.Schema
  import Ecto.Changeset

  schema "shapes" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(shape, attrs) do
    shape
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
