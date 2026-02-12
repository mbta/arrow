defmodule ArrowWeb.DisruptionV2Controller.Filters do
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
          kinds: MapSet.t(atom()),
          only_approved?: boolean(),
          only_archived?: boolean(),
          view: Calendar.t() | Table.t()
        }

  defstruct kinds: @empty_set,
            only_approved?: false,
            only_archived?: false,
            search: nil,
            view: %Table{}

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

    search =
      if params["search"] in [nil, ""] or String.trim(params["search"]) == "",
        do: nil,
        else: params["search"]

    %__MODULE__{
      kinds:
        params |> Map.get("kinds", []) |> Enum.map(&String.to_existing_atom/1) |> MapSet.new(),
      only_approved?: not is_nil(params["only_approved"]),
      only_archived?: not is_nil(params["only_archived"]),
      search: search,
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

  @spec toggle_only_approved(t()) :: t()
  def toggle_only_approved(%__MODULE__{only_approved?: only_approved} = filters) do
    %__MODULE__{filters | only_approved?: !only_approved, only_archived?: false}
  end

  @spec toggle_only_archived(t()) :: t()
  def toggle_only_archived(%__MODULE__{only_archived?: only_archived} = filters) do
    %__MODULE__{filters | only_archived?: !only_archived, only_approved?: false}
  end

  @spec toggle_view(%__MODULE__{}) :: %__MODULE__{}
  def toggle_view(%__MODULE__{view: %Calendar{}} = filters), do: %{filters | view: %Table{}}
  def toggle_view(%__MODULE__{view: %Table{}} = filters), do: %{filters | view: %Calendar{}}

  @impl true
  def to_params(%__MODULE__{
        kinds: kinds,
        only_approved?: only_approved?,
        only_archived?: only_archived?,
        search: search,
        view: %{__struct__: view_mod} = view
      }) do
    %{}
    |> put_if(view_mod == Calendar, "view", "calendar")
    |> put_if(
      kinds != @empty_set,
      "kinds",
      kinds |> MapSet.to_list() |> Enum.map(&to_string/1) |> Enum.sort()
    )
    |> put_if(only_approved?, "only_approved", "true")
    |> put_if(only_archived?, "only_archived", "true")
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
