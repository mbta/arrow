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
  import Ecto.Query
  alias Arrow.Repo

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

  @doc "Returns all adjustments, sorted by label."
  @spec all() :: [t()]
  def all, do: Repo.all(from a in __MODULE__, order_by: :source_label)

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(adjustment, attrs) do
    adjustment
    |> cast(attrs, [:source, :source_label, :route_id])
    |> validate_required([:source, :source_label, :route_id])
    |> unique_constraint(:source_label)
  end

  @doc """
  Fetches the adjustments corresponding to the given `DisruptionRevision` changeset parameters.
  Allows us to `put_assoc` adjustments when building a revision changeset, since `many_to_many`
  associations don't support updating values in the join table using `cast_assoc`.
  """
  @spec from_revision_attrs(%{String.t() => any}) :: [t()]
  def from_revision_attrs(%{"adjustments" => adjustments}) do
    ids = adjustments |> Enum.map(& &1["id"]) |> Enum.reject(&(&1 in [nil, ""]))
    Repo.all(from a in __MODULE__, where: a.id in ^ids)
  end

  def from_revision_attrs(_), do: []
end
