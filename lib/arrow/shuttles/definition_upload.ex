defmodule Arrow.Shuttles.DefinitionUpload do
  @moduledoc "functions for extracting shuttle defintions from xlsx uploads"
  alias Arrow.Shuttles.Stop

  @direction_0_tab_name "Direction 0 STOPS"
  @direction_1_tab_name "Direction 1 STOPS"

  @doc """
  Parses a shuttle definition xlsx worksheet and returns a list of two stop_id lists
  """
  @spec extract_stop_ids_from_upload(%{path: String.t()}) ::
          {:ok, {list(Stop.id()), list(Stop.id())} | {:error, [String.t(), ...]}}
  def extract_stop_ids_from_upload(%{path: xlsx_path}) do
    with tids when is_list(tids) <- Xlsxir.multi_extract(xlsx_path),
         {:ok, tab_map} <- get_xlsx_tab_tids(tids),
         {{:ok, direction_0_stop_ids}, {:ok, direction_1_stop_ids}} <-
           parse_direction_tabs(tab_map) do
      {:ok, {direction_0_stop_ids, direction_1_stop_ids}}
    else
      {:error, error} -> {:ok, {:error, [error]}}
      {:errors, errors} -> {:ok, {:error, errors}}
    end
  end

  defp get_xlsx_tab_tids(tab_tids) do
    tab_map =
      Enum.reduce(tab_tids, %{}, fn {:ok, tid}, acc ->
        name = Xlsxir.get_info(tid, :name)

        if name in [@direction_0_tab_name, @direction_1_tab_name] do
          Map.put(acc, name, tid)
        else
          Xlsxir.close(tid)
          acc
        end
      end)

    case {tab_map[@direction_0_tab_name], tab_map[@direction_1_tab_name]} do
      {nil, nil} -> {:error, "Missing tabs for both directions"}
      {nil, _} -> {:error, "Missing #{@direction_0_tab_name} tab"}
      {_, nil} -> {:error, "Missing #{@direction_1_tab_name} tab"}
      _ -> {:ok, tab_map}
    end
  end

  defp parse_direction_tabs(%{@direction_0_tab_name => direction_0_tab_tid, @direction_1_tab_name => direction_1_tab_tid}) do
    case {parse_direction_tab(direction_0_tab_tid, @direction_0_tab_name),
          parse_direction_tab(direction_1_tab_tid, @direction_1_tab_name)} do
      {{:errors, errors0}, {:errors, errors1}} -> {:errors, errors0 ++ errors1}
      {{:errors, errors}, _} -> {:errors, errors}
      {_, {:errors, errors}} -> {:errors, errors}
      result -> result
    end
  end

  defp parse_direction_tab(tab_id, tab_name) do
    tab_id
    |> Xlsxir.get_list()
    # Cells that have been touched but are empty can return nil
    |> Enum.reject(fn list -> Enum.all?(list, &is_nil/1) end)
    |> tap(fn _ -> Xlsxir.close(tab_id) end)
    |> parse_stop_ids(tab_name)
  end

  defp parse_stop_ids([headers | _] = data, tab_name) do
    if stop_id_col_index = Enum.find_index(headers, &(&1 == "Stop ID")) do
      stop_ids = data |> Enum.drop(1) |> Enum.map(&Enum.at(&1, stop_id_col_index))

      errors =
        stop_ids
        |> Enum.with_index(1)
        |> Enum.reduce([], fn {stop_id, i}, acc ->
          prepend_if(
            acc,
            is_nil(stop_id) or not is_integer(stop_id),
            "Tab #{tab_name}, row #{i + 1}: missing/invalid stop ID"
          )
        end)
        |> Enum.reverse()

      if Enum.empty?(errors) do
        {:ok, Enum.map(stop_ids, &Integer.to_string(&1))}
      else
        {:errors, errors}
      end
    else
      {:errors, ["Unable to parse Stop ID column"]}
    end
  end

  defp prepend_if(list, condition, item) do
    if condition, do: [item | list], else: list
  end
end
