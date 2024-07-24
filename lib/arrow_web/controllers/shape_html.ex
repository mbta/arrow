defmodule ArrowWeb.ShapeView do
  use ArrowWeb, :html
  alias Arrow.Shuttle.ShapesUpload
  require Logger

  embed_templates "shape_html/*"

  @doc """
  Renders a shape form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def shape_form(assigns)

  def shapes_map_view(%ShapesUpload{shapes: shapes}) do
    %{shapes: Enum.map(shapes, &shape_map_view/1)}
  end

  def shapes_map_view(%{params: %{"shapes" => shapes}}) do
    %{shapes: Enum.map(shapes, &shape_map_view/1)}
  end

  defp shape_map_view(%{coordinates: coordinates, name: name}) do
    %{
      coordinates: map_coordinates(coordinates),
      name: name
    }
  end

  defp map_coordinates(coordinates) do
    Enum.map(coordinates, &process_coordinate_pair/1)
  end

  defp process_coordinate_pair(coordinate_pair) do
    coordinate_pair
    |> String.split(",")
    |> Enum.map(&String.to_float/1)
    |> Enum.reverse()
  end
end
