defmodule ArrowWeb.DisruptionController.Filters.Table do
  @moduledoc "Handles filters unique to the table view."

  @behaviour ArrowWeb.DisruptionController.Filters.Behaviour

  import ArrowWeb.DisruptionController.Filters.Helpers

  @type sort :: :id | :source_label | :start_date
  @type t :: %__MODULE__{include_past?: boolean, sort: {:asc | :desc, sort}}

  defstruct include_past?: false, sort: {:asc, :source_label}

  @impl true
  def from_params(params) when is_map(params) do
    %__MODULE__{
      include_past?: not is_nil(params["include_past"]),
      sort: parse_sort(params["sort"])
    }
  end

  @impl true
  def resettable?(%__MODULE__{include_past?: true}), do: true
  def resettable?(_), do: false

  @impl true
  def reset(%__MODULE__{} = table), do: %{table | include_past?: false}

  @impl true
  def to_params(%__MODULE__{include_past?: include_past, sort: sort}) do
    %{}
    |> put_if(include_past, "include_past", "true")
    |> put_if(sort != %__MODULE__{}.sort, "sort", encode_sort(sort))
  end

  defp encode_sort({:asc, field}), do: to_string(field)
  defp encode_sort({:desc, field}), do: "-" <> to_string(field)

  defp parse_sort(nil), do: %__MODULE__{}.sort
  defp parse_sort("-" <> sort), do: {:desc, String.to_existing_atom(sort)}
  defp parse_sort(sort), do: {:asc, String.to_existing_atom(sort)}
end
