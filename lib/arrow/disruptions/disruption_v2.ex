defmodule Arrow.Disruptions.DisruptionV2 do
  use Ecto.Schema
  import Ecto.Changeset

  schema "disruptionsv2" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(disruption_v2, attrs) do
    disruption_v2
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
