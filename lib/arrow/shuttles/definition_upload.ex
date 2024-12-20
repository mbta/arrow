defmodule Arrow.Shuttles.DefinitionUpload do
  @moduledoc "functions for extracting shuttle defintions from xlsx uploads"
  alias Arrow.Shuttles.Stop

  @doc """
  Parses a shuttle definition xlsx worksheet and returns a list of two stop_id lists
  """
  @spec extract_stop_ids_from_upload(%{path: String.t()}) ::
          {:ok, {list(Stop.id()), list(Stop.id())} | {:error, [String.t(), ...]}}
  def extract_stop_ids_from_upload(%{path: xlsx_path}) do
    with tids when is_list(tids) <- Xlsxir.multi_extract(xlsx_path),
         {:ok,
          %{
            "Direction 0 STOPS" => direction_0_tab_tid,
            "Direction 1 STOPS" => direction_1_tab_tid
          }} <- get_xlsx_tab_tids(tids),
         {:ok, direction_0_stop_ids} <- parse_direction_tab(direction_0_tab_tid),
         {:ok, direction_1_stop_ids} <- parse_direction_tab(direction_1_tab_tid) do
      {:ok, {direction_0_stop_ids, direction_1_stop_ids}}
    else
      {:error, error} -> {:ok, {:error, [error]}}
      {:errors, errors} -> {:ok, {:error, errors}}
    end
  end

  defp get_xlsx_tab_tids(tab_tids) do
    tab_map =
      tab_tids
      |> Enum.map(fn {:ok, tid} ->
        name = Xlsxir.get_info(tid, :name)

        if name in ["Direction 0 STOPS", "Direction 1 STOPS"] do
          {name, tid}
        else
          Xlsxir.close(tid)
          nil
        end
      end)
      |> Enum.reject(&is_nil/1)
      |> Map.new()

    case {tab_map["Direction 0 STOPS"], tab_map["Direction 1 STOPS"]} do
      {nil, nil} -> {:error, "Missing tabs for both directions"}
      {nil, _} -> {:error, "Missing Direction 0 STOPS tab"}
      {_, nil} -> {:error, "Missing Direction 1 STOPS tab"}
      _ -> {:ok, tab_map}
    end
  end

  def parse_direction_tab(table_id) do
    tab_data =
      table_id
      |> Xlsxir.get_list()
      # Cells that have been touched but are empty can return nil
      |> Enum.reject(fn list -> Enum.all?(list, &is_nil/1) end)
      |> tap(fn _ -> Xlsxir.close(table_id) end)

    parse_stop_ids(tab_data)
  end

  defp parse_stop_ids([headers | _] = data) do
    if stop_id_col_index = Enum.find_index(headers, &(&1 === "Stop ID")) do
      stop_ids = data |> Enum.drop(1) |> Enum.map(&Enum.at(&1, stop_id_col_index))

      errors =
        stop_ids
        |> Enum.with_index(1)
        |> Enum.reduce([], fn {stop_id, i}, acc ->
          append_if(
            acc,
            is_nil(stop_id) or not is_integer(stop_id),
            "Missing/invalid stop ID on row #{i + 1}"
          )
        end)

      if Enum.empty?(errors), do: {:ok, stop_ids}, else: {:errors, errors}
    else
      {:errors, ["Unable to parse Stop ID column"]}
    end
  end

  defp append_if(list, condition, item) do
    if condition, do: [item | list], else: list
  end
end
