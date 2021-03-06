defmodule Arrow.Adjustment do
  @moduledoc """
  Adjustment: a change to a particular route which can be activated.

  In practice, a function from a list of trips (on the given route) to a list
  of trips (on the given route or not). Analogous to the current Shuttle in
  gtfs_creator.

  Examples:
  - Green-D: Kenmore to Newton Highlands shuttle
  - Red: Broadway to Kendall/MIT shuttle
  - Silver: Line running on the surface
  - Green-C: Haymarket Station closed (trains do not pass through)
  - Green-E: Haymarket Station closed (trains do not pass through)
  - Red: Wollaston closed (trains run through the station)
  - 87: rerouted around Davis Square
  - Mattapan: replaced with shuttles
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          route_id: String.t() | nil,
          source: String.t() | nil,
          source_label: String.t() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  schema "adjustments" do
    field :route_id, :string
    field :source, :string
    field :source_label, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(adjustment, attrs) do
    adjustment
    |> cast(attrs, [:source, :source_label, :route_id])
    |> validate_required([:source, :source_label, :route_id])
    |> unique_constraint(:source_label)
  end

  @spec changeset_assoc(t(), map()) :: Ecto.Changeset.t()
  def changeset_assoc(adjustment, attrs) do
    cast(adjustment, attrs, [:id])
  end
end
