defmodule ArrowWeb.DisruptionV2Controller.Filters.Table do
  @moduledoc "Handles filters unique to the table view."

  import ArrowWeb.DisruptionController.Filters.Helpers

  @type direction :: :asc | :desc
  @type sortable_field :: :start_date | :end_date
  @type t :: %__MODULE__{
          include_past?: boolean,
          sort: %{sortable_field => direction},
          active_sort: sortable_field
        }

  defstruct include_past?: false,
            sort: %{start_date: :desc, end_date: :desc},
            active_sort: :start_date

  def from_params(params) when is_map(params) do
    %__MODULE__{
      include_past?: not is_nil(params["include_past"]),
      sort: parse_sort(params["sort"]),
      active_sort: parse_active_sort(params["active_sort"])
    }
  end

  def resettable?(%__MODULE__{include_past?: true}), do: true
  def resettable?(_), do: false

  def reset(%__MODULE__{} = table), do: %{table | include_past?: false}

  def to_params(%__MODULE__{include_past?: include_past, sort: sort, active_sort: active_sort}) do
    %{}
    |> put_if(include_past, "include_past", "true")
    |> put_if(sort != %__MODULE__{}.sort, "sort", encode_sort(sort))
    |> put_if(
      active_sort != %__MODULE__{}.active_sort,
      "active_sort",
      encode_active_sort(active_sort)
    )
  end

  defp encode_sort(sort) do
    Enum.map_join(sort, ",", fn
      {field, :desc} -> "-" <> to_string(field)
      {field, :asc} -> to_string(field)
    end)
  end

  defp parse_sort(nil), do: %__MODULE__{}.sort

  defp parse_sort(sort) do
    sort
    |> String.split(",", trim: true)
    |> Map.new(fn
      "-" <> field -> {String.to_existing_atom(field), :desc}
      field -> {String.to_existing_atom(field), :asc}
    end)
  end

  defp encode_active_sort(active_sort), do: to_string(active_sort)

  defp parse_active_sort(nil), do: %__MODULE__{}.active_sort
  defp parse_active_sort(active_sort), do: String.to_existing_atom(active_sort)
end
