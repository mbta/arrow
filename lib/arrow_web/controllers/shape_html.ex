defmodule ArrowWeb.ShapeView do
  use ArrowWeb, :html

  alias Arrow.Gtfs.Stop, as: GtfsStop
  alias Arrow.Shuttles
  alias Arrow.Shuttles.Route
  alias Arrow.Shuttles.RouteStop
  alias Arrow.Shuttles.Shape
  alias Arrow.Shuttles.ShapesUpload
  alias Arrow.Shuttles.Stop, as: ArrowStop
  alias Phoenix.Controller

  embed_templates "shape_html/*"

  @doc """
  Renders a shape form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def shape_form(assigns)

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
    case Shuttles.get_shapes_upload(shape) do
      {:ok, shapes_upload} ->
        shapes_upload
        |> ShapesUpload.shapes_map_view()
        |> Map.get(:shapes)
        |> List.first()

      {:error, _} ->
        nil
    end
  end

  defp shape_to_shapeview(_), do: nil

  defp render_route_stop(%RouteStop{stop_id: stop_id} = route_stop) when not is_nil(stop_id) do
    stop = Arrow.Repo.get(ArrowStop, stop_id)

    if stop do
      %{
        stop_sequence: route_stop.stop_sequence,
        stop_id: stop.stop_id,
        stop_name: stop.stop_name,
        stop_desc: stop.stop_desc,
        stop_lat: stop.stop_lat,
        stop_lon: stop.stop_lon,
        stop_source: :arrow
      }
    end
  end

  defp render_route_stop(%RouteStop{gtfs_stop_id: gtfs_stop_id} = route_stop) when not is_nil(gtfs_stop_id) do
    gtfs_stop = Arrow.Repo.get(GtfsStop, gtfs_stop_id)

    if gtfs_stop do
      %{
        stop_sequence: route_stop.stop_sequence,
        stop_id: gtfs_stop.id,
        stop_name: gtfs_stop.name,
        stop_desc: gtfs_stop.desc,
        stop_lat: gtfs_stop.lat,
        stop_lon: gtfs_stop.lon,
        stop_source: :gtfs
      }
    end
  end

  defp render_route_stop(_), do: nil

  defp render_route_stops([_ | _] = route_stops) do
    route_stops |> Enum.map(&render_route_stop/1) |> Enum.filter(& &1)
  end

  defp render_route_stops(_), do: []
end
