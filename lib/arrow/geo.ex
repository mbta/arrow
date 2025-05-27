defmodule Arrow.Geo do
  @moduledoc """
  Geographic utility functions for calculating distances between points and shapes.
  """

  @earth_radius_meters 6_371_000

  @doc """
  Calculates the distance in meters between two geographic points using the Haversine formula.
  """
  @spec haversine_distance({float(), float()}, {float(), float()}) :: float()
  def haversine_distance({lat1, lon1}, {lat2, lon2}) do
    lat1_rad = lat1 * :math.pi() / 180
    lat2_rad = lat2 * :math.pi() / 180
    dlat = (lat2 - lat1) * :math.pi() / 180
    dlon = (lon2 - lon1) * :math.pi() / 180

    a =
      :math.sin(dlat / 2) * :math.sin(dlat / 2) +
        :math.cos(lat1_rad) * :math.cos(lat2_rad) *
          :math.sin(dlon / 2) * :math.sin(dlon / 2)

    c = 2 * :math.atan2(:math.sqrt(a), :math.sqrt(1 - a))

    @earth_radius_meters * c
  end

  @doc """
  Calculates the minimum distance from a point to a polyline (shape).
  Returns the distance in meters.
  """
  @spec distance_from_point_to_shape({float(), float()}, [[float()]]) :: float()
  def distance_from_point_to_shape(point, shape_coordinates) do
    shape_coordinates
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [coord1, coord2] ->
      distance_to_segment(point, List.to_tuple(coord1), List.to_tuple(coord2))
    end)
    |> Enum.min()
  end

  @doc """
  Calculates the distance from a point to a line segment.
  """
  @spec distance_to_segment({float(), float()}, {float(), float()}, {float(), float()}) :: float()
  def distance_to_segment(point, segment_start, segment_end) do
    {px, py} = point
    {x1, y1} = segment_start
    {x2, y2} = segment_end

    dx = x2 - x1
    dy = y2 - y1

    if dx == 0 and dy == 0 do
      haversine_distance(point, segment_start)
    else
      t = ((px - x1) * dx + (py - y1) * dy) / (dx * dx + dy * dy)

      t = max(0, min(1, t))

      closest_point = {x1 + t * dx, y1 + t * dy}

      haversine_distance(point, closest_point)
    end
  end
end
