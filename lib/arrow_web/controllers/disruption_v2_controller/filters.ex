defmodule ArrowWeb.DisruptionV2Controller.Filters do
  @moduledoc """
  Handles parsing, encoding, and updating the filters that can be applied to the disruptions
  index. For the purposes of this module, all parameters that are part of the "state" of the
  index (including e.g. sorting, in the table view) are considered filters.
  """

  alias __MODULE__.{Calendar, Table}
  import __MODULE__.Helpers

  alias Arrow.Disruptions.DisruptionV2

  @empty_set MapSet.new()

  defmodule Behaviour do
    @moduledoc "Required behaviour for `Filters` sub-modules."
    @callback from_params(Plug.Conn.params()) :: struct
    @callback resettable?(struct) :: boolean
    @callback reset(struct) :: struct
    @callback to_params(struct) :: Plug.Conn.params()
  end

  @behaviour Behaviour

  @type t :: %__MODULE__{kinds: MapSet.t(atom()), view: Calendar.t() | Table.t()}

  defstruct kinds: @empty_set, only_approved?: false, search: nil, view: %Table{}

  @disruption_kind_routes %{
    blue_line: ["Blue"],
    orange_line: ["Orange"],
    red_line: ["Red"],
    mattapan_line: ["Mattapan"],
    green_line: ["Green-B", "Green-C", "Green-D", "Green-E"],
    green_line_b: ["Green-B"],
    green_line_c: ["Green-C"],
    green_line_d: ["Green-D"],
    green_line_e: ["Green-E"]
  }

  @spec calendar?(%__MODULE__{}) :: boolean
  def calendar?(%__MODULE__{view: %Calendar{}}), do: true
  def calendar?(%__MODULE__{view: %Table{}}), do: false

  @spec flatten(%__MODULE__{}) :: %{atom => any}
  def flatten(%__MODULE__{view: view} = filters) do
    filters |> Map.from_struct() |> Map.delete(:view) |> Map.merge(Map.from_struct(view))
  end

  @impl true
  def from_params(params) when is_map(params) do
    view_mod = if(params["view"] == "calendar", do: Calendar, else: Table)

    %__MODULE__{
      kinds:
        params |> Map.get("kinds", []) |> Enum.map(&String.to_existing_atom/1) |> MapSet.new(),
      view: view_mod.from_params(params)
    }
  end

  @impl true
  def resettable?(%__MODULE__{view: %{__struct__: view_mod} = view} = filters) do
    %{filters | view: nil} != %__MODULE__{view: nil} or view_mod.resettable?(view)
  end

  @impl true
  def reset(%__MODULE__{view: %{__struct__: view_mod} = view}) do
    %__MODULE__{view: view_mod.reset(view)}
  end

  @spec toggle_kind(%__MODULE__{}, atom()) :: %__MODULE__{}
  def toggle_kind(%__MODULE__{kinds: kinds} = filters, kind) do
    new_kinds = if(kind in kinds, do: MapSet.delete(kinds, kind), else: MapSet.put(kinds, kind))
    struct!(filters, kinds: new_kinds)
  end

  @spec toggle_view(%__MODULE__{}) :: %__MODULE__{}
  def toggle_view(%__MODULE__{view: %Calendar{}} = filters), do: %{filters | view: %Table{}}
  def toggle_view(%__MODULE__{view: %Table{}} = filters), do: %{filters | view: %Calendar{}}

  @impl true
  def to_params(%__MODULE__{
        kinds: kinds,
        view: %{__struct__: view_mod} = view
      }) do
    %{}
    |> put_if(view_mod == Calendar, "view", "calendar")
    |> put_if(
      kinds != @empty_set,
      "kinds",
      kinds |> MapSet.to_list() |> Enum.map(&to_string/1) |> Enum.sort()
    )
    |> Map.merge(view_mod.to_params(view))
  end

  @spec to_flat_params(%__MODULE__{}) :: [{String.t(), String.t()}]
  def to_flat_params(%__MODULE__{} = filters) do
    filters
    |> to_params()
    |> Enum.flat_map(fn
      {key, value} when is_list(value) -> Enum.map(value, &{"#{key}[]", &1})
      {key, value} -> [{key, value}]
    end)
  end

  @spec apply_to_disruptions([DisruptionV2.t()], t()) :: [DisruptionV2.t()]
  def apply_to_disruptions(disruptions, filters) do
    disruptions
    |> Enum.filter(fn disruption ->
      apply_kinds_filter(disruption, filters)
    end)
  end

  defp apply_kinds_filter(_disruption, %__MODULE__{kinds: kinds}) when kinds == @empty_set,
    do: true

  defp apply_kinds_filter(disruption, %__MODULE__{kinds: kinds}) do
    kind_routes = kinds |> Enum.map(&@disruption_kind_routes[&1]) |> List.flatten()

    Enum.any?(disruption.limits, fn limit -> limit.route.id in kind_routes end)
  end
end
