defmodule ArrowWeb.DisruptionController.Filters.Helpers do
  @moduledoc "Functions shared by the `Filters` modules."

  @spec put_if(map, boolean, any, any) :: map
  def put_if(map, true, key, value), do: Map.put(map, key, value)
  def put_if(map, false, _, _), do: map
end
