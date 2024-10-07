defmodule Arrow.Shuttles.Shuttle do
  use Ecto.Schema
  import Ecto.Changeset

  schema "shuttles" do
    field :status, Ecto.Enum, values: [:draft, :active, :inactive]
    field :shuttle_name, :string
    field :disrupted_route_id, :string

    timestamps()
  end

  @doc false
  def changeset(shuttle, attrs) do
    shuttle
    |> cast(attrs, [:shuttle_name, :status, :disrupted_route_id])
    |> foreign_key_constraint(:disrupted_route_id)
    |> validate_required([:shuttle_name, :status])
    |> unique_constraint(:shuttle_name)
  end
end
