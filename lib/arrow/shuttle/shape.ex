defmodule Arrow.Shuttle.Shape do
  @moduledoc "schema for shuttle shapes"
  use Ecto.Schema
  import Ecto.Changeset

  @type id :: integer
  @type t :: %__MODULE__{
    id: id,
    name: String.t(),
    coordinates: list(String.t()),
    inserted_at: DateTime.t(),
    updated_at: DateTime.t()
  }

  schema "shapes" do
    field :name, :string
    field :coordinates, {:array, :string}

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(shape, attrs) do
    shape
    |> cast(attrs, [:name, :coordinates])
    |> validate_required([:name, :coordinates])
    |> unique_constraint(:name)
  end
end
