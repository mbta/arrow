defmodule Arrow.Shuttle.Shape do
  @moduledoc "schema for shuttle shapes"
  use Ecto.Schema
  import Ecto.Changeset

  schema "shapes" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(shape, attrs) do
    shape
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
