defmodule Arrow.Shuttle.Shape do
  @moduledoc "schema for shuttle shapes"
  use Ecto.Schema
  import Ecto.Changeset

  schema "shapes" do
    field :name, :string
    field :bucket, :string
    field :path, :string
    field :prefix, :string

    timestamps()
  end

  @doc false
  def changeset(shape, attrs) do
    shape
    |> cast(attrs, [:name, :path, :bucket, :prefix])
    |> validate_required([:name, :path, :bucket, :prefix])
    |> unique_constraint(:name)
  end
end
