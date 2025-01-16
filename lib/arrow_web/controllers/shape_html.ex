defmodule ArrowWeb.ShapeView do
  use ArrowWeb, :html
  alias Arrow.Shuttles
  alias Arrow.Shuttles.Route
  alias Arrow.Shuttles.RouteStop
  alias Arrow.Shuttles.Shape
  alias Arrow.Shuttles.ShapesUpload

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

  def shapes_map_view({:ok, :disabled}), do: %{}

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

  defp direction_to_layer(%Route{} = direction, existing_props) do
    matching_shape =
      existing_props.layers
      |> Enum.map(& &1.shape)
      |> Enum.find(&(&1 && direction.shape_id && &1.name == direction.shape.name))

    shape = if matching_shape, do: matching_shape, else: shape_to_shapeview(direction.shape)

    stops = render_route_stops(direction.route_stops)

    %{
      name: direction.direction_desc,
      direction_id: direction.direction_id,
      shape: shape,
      stops: stops
    }
  end

  def routes_to_layers(routes, existing_props) do
    routes
    |> Enum.sort_by(& &1.direction_id)
    |> Enum.map(&direction_to_layer(&1, existing_props))
  end

  def routes_to_layers(routes) do
    routes_to_layers(routes, %{layers: []})
  end

  defp shape_to_shapeview(%Shape{bucket: "disabled"}), do: nil

  defp shape_to_shapeview(%Shape{} = shape) do
    shape
    |> Shuttles.get_shapes_upload()
    |> shapes_map_view()
    |> Map.get(:shapes)
    |> List.first()
  end

  defp shape_to_shapeview(_), do: nil

  defp render_route_stop(%RouteStop{stop_id: stop_id} = route_stop) when not is_nil(stop_id) do
    route_stop =
      if !Ecto.assoc_loaded?(route_stop.stop) or
           (route_stop.stop && route_stop.stop.id != stop_id),
         do: Arrow.Repo.preload(route_stop, :stop, force: true),
         else: route_stop

    if route_stop.stop do
      %{
        stop_sequence: route_stop.stop_sequence,
        stop_id: route_stop.stop.stop_id,
        stop_name: route_stop.stop.stop_name,
        stop_desc: route_stop.stop.stop_desc,
        stop_lat: route_stop.stop.stop_lat,
        stop_lon: route_stop.stop.stop_lon
      }
    end
  end

  defp render_route_stop(%RouteStop{gtfs_stop_id: gtfs_stop_id} = route_stop)
       when not is_nil(gtfs_stop_id) do
    route_stop =
      if !Ecto.assoc_loaded?(route_stop.gtfs_stop) or
           (route_stop.gtfs_stop && route_stop.gtfs_stop.id != gtfs_stop_id),
         do: Arrow.Repo.preload(route_stop, :gtfs_stop, force: true),
         else: route_stop

    if route_stop.gtfs_stop do
      %{
        stop_sequence: route_stop.stop_sequence,
        stop_id: route_stop.gtfs_stop.id,
        stop_name: route_stop.gtfs_stop.name,
        stop_desc: route_stop.gtfs_stop.desc,
        stop_lat: route_stop.gtfs_stop.lat,
        stop_lon: route_stop.gtfs_stop.lon
      }
    end
  end

  defp render_route_stop(_), do: nil

  defp render_route_stops([_ | _] = route_stops) do
    route_stops |> Enum.map(&render_route_stop/1) |> Enum.filter(& &1)
  end

  defp render_route_stops(_), do: []
end
