defmodule Arrow.Disruptions.DisruptionV2 do
  use Ecto.Schema
  import Ecto.Changeset

  schema "disruptionsv2" do
    field :title, :string
    field :mode, :string
    field :is_active, :boolean
    field :description, :string

    timestamps()
  end

  @doc false
  def changeset(disruption_v2, attrs) do
    disruption_v2
    |> cast(attrs, [:title, :mode, :is_active, :description])
    |> validate_required([:title, :mode, :is_active, :description])
  end
end
