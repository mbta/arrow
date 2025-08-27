defmodule Arrow.Adjustment do
  @moduledoc """
  Represents a change to a route, which can be activated by a disruption. Known as "shuttles" in
  gtfs_creator, though the change may or may not involve a shuttle (e.g. a closed subway station,
  or a re-routed bus route).
  """

  use Arrow.Schema

  import Ecto.Changeset
  import Ecto.Query
  alias Arrow.Repo

  typed_schema "adjustments" do
    field :route_id, :string
    field :source, :string
    field :source_label, :string

    timestamps(type: :utc_datetime)
  end

  # See also the `DisruptionForm` React component
  @kinds ~w(
    blue_line
    orange_line
    red_line
    mattapan_line
    green_line
    green_line_b
    green_line_c
    green_line_d
    green_line_e
    commuter_rail
    silver_line
    bus
  )a

  @silver_line_routes ~w(741 742 743 746 747 749 751)

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
  Returns a version of the adjustment's `source_label` with spaces between words. Attempts to
  correctly handle uppercased acronyms such as "JFK" or "SL2".
  """
  @spec display_label(t()) :: String.t()
  def display_label(%__MODULE__{source_label: source_label}) do
    source_label
    |> String.replace(~r/([[:lower:]])([[:upper:]\d])/, "\\1 \\2")
    |> String.replace(~r/([[:upper:]\d])([[:upper:]\d])(?=[[:lower:]])/, "\\1 \\2")
  end

  @doc """
  Returns all possible "kinds" of adjustment, an Arrow-specific categorization that doesn't
  correspond exactly to a route ID or route type. These are used to unify handling of disruptions
  that have adjustments, and disruptions where a new adjustment is being requested.
  """
  @spec kinds() :: [atom()]
  def kinds, do: @kinds

  @doc "Determines the kind of an adjustment."
  @spec kind(t()) :: atom()
  def kind(%__MODULE__{route_id: "Blue"}), do: :blue_line
  def kind(%__MODULE__{route_id: "Orange"}), do: :orange_line
  def kind(%__MODULE__{route_id: "Red"}), do: :red_line
  def kind(%__MODULE__{route_id: "Mattapan"}), do: :mattapan_line
  def kind(%__MODULE__{route_id: "Green-B"}), do: :green_line_b
  def kind(%__MODULE__{route_id: "Green-C"}), do: :green_line_c
  def kind(%__MODULE__{route_id: "Green-D"}), do: :green_line_d
  def kind(%__MODULE__{route_id: "Green-E"}), do: :green_line_e
  def kind(%__MODULE__{route_id: "CR-" <> _}), do: :commuter_rail
  def kind(%__MODULE__{route_id: id}) when id in @silver_line_routes, do: :silver_line
  def kind(%__MODULE__{}), do: :bus

  @doc """
  Builds an Ecto `where` fragment for selecting adjustments with the given kind. Assumes a named
  binding `adjustments`. Bus adjustments are not yet supported in general, so we assume there are
  none in the database.
  """
  # credo:disable-for-next-line
  @spec kind_is(atom()) :: %Ecto.Query.DynamicExpr{}
  def kind_is(:blue_line), do: dynamic([adjustments: a], a.route_id == "Blue")
  def kind_is(:orange_line), do: dynamic([adjustments: a], a.route_id == "Orange")
  def kind_is(:red_line), do: dynamic([adjustments: a], a.route_id == "Red")
  def kind_is(:mattapan_line), do: dynamic([adjustments: a], a.route_id == "Mattapan")
  def kind_is(:green_line), do: dynamic(false)
  def kind_is(:green_line_b), do: dynamic([adjustments: a], a.route_id == "Green-B")
  def kind_is(:green_line_c), do: dynamic([adjustments: a], a.route_id == "Green-C")
  def kind_is(:green_line_d), do: dynamic([adjustments: a], a.route_id == "Green-D")
  def kind_is(:green_line_e), do: dynamic([adjustments: a], a.route_id == "Green-E")
  def kind_is(:commuter_rail), do: dynamic([adjustments: a], like(a.route_id, "CR-%"))
  def kind_is(:silver_line), do: dynamic([adjustments: a], a.route_id in @silver_line_routes)
  def kind_is(:bus), do: dynamic(false)

  @doc "Returns the index of the given adjustment kind in `kinds/0`, used for sorting kinds."
  @spec kind_order(atom()) :: non_neg_integer()
  for {kind, index} <- Enum.with_index(@kinds) do
    def kind_order(unquote(kind)), do: unquote(index)
  end
end
