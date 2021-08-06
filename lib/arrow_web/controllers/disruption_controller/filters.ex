defmodule ArrowWeb.DisruptionController.Filters do
  @moduledoc """
  Handles parsing, encoding, and updating the filters that can be applied to the disruptions
  index. For the purposes of this module, all parameters that are part of the "state" of the
  index (including e.g. sorting, in the table view) are considered filters.
  """

  alias __MODULE__.{Calendar, Table}
  import __MODULE__.Helpers

  @empty_set MapSet.new()

  defmodule Behaviour do
    @moduledoc "Required behaviour for `Filters` sub-modules."
    @callback from_params(Plug.Conn.params()) :: struct
    @callback resettable?(struct) :: boolean
    @callback reset(struct) :: struct
    @callback to_params(struct) :: Plug.Conn.params()
  end

  @behaviour Behaviour

  @type t :: %__MODULE__{
          routes: MapSet.t(String.t()),
          search: String.t() | nil,
          view: Calendar.t() | Table.t()
        }

  defstruct routes: @empty_set, search: nil, view: %Table{}

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
      routes: params |> Map.get("routes", []) |> MapSet.new(),
      search: if(params["search"] in [nil, ""], do: nil, else: params["search"]),
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

  @spec toggle_route(%__MODULE__{}, String.t()) :: %__MODULE__{}
  def toggle_route(%__MODULE__{routes: routes} = filters, route) do
    new_routes =
      if(route in routes, do: MapSet.delete(routes, route), else: MapSet.put(routes, route))

    struct!(filters, routes: new_routes)
  end

  @spec toggle_view(%__MODULE__{}) :: %__MODULE__{}
  def toggle_view(%__MODULE__{view: %Calendar{}} = filters), do: %{filters | view: %Table{}}
  def toggle_view(%__MODULE__{view: %Table{}} = filters), do: %{filters | view: %Calendar{}}

  @impl true
  def to_params(%__MODULE__{routes: routes, search: search, view: %{__struct__: view_mod} = view}) do
    %{}
    |> put_if(view_mod == Calendar, "view", "calendar")
    |> put_if(routes != @empty_set, "routes", routes |> MapSet.to_list() |> Enum.sort())
    |> put_if(not is_nil(search), "search", search)
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
end
