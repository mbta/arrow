defmodule Arrow.Shuttles.Shuttle do
  @moduledoc "schema for a shuttle for the db"
  use Ecto.Schema
  import Ecto.Changeset

  schema "shuttles" do
    field :status, Ecto.Enum, values: [:draft, :active, :inactive]
    field :shuttle_name, :string
    field :disrupted_route_id, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(shuttle, attrs) do
    shuttle
    |> cast(attrs, [:shuttle_name, :disrupted_route_id, :status])
    |> validate_required([:shuttle_name, :status])
    |> foreign_key_constraint(:disrupted_route_id)
    |> unique_constraint(:shuttle_name)
  end
end
