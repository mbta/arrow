defmodule Arrow.OpenRouteServiceAPI do
  @moduledoc """
  The OpenRouteServiceAPI context.
  """

  alias Arrow.OpenRouteServiceAPI.DirectionsRequest
  alias Arrow.OpenRouteServiceAPI.DirectionsResponse

  @doc """
  Returns a response from OpenRouteService containing coordinates of a route shape.

  The coordinates in both the input and the output for `directions/1` are formatted
  as maps with keys `lat` and `lon`.

  If no coordinates are given, or only one is, then `directions/1` will bypass the actual
  API call and just return a response with an empty route shape.

  ## Examples
      iex> Arrow.OpenRouteServiceAPI.directions([])
      {:ok, %Arrow.OpenRouteServiceAPI.DirectionsResponse{coordinates: [], segments: [], summary: %{}}}

      iex> Arrow.OpenRouteServiceAPI.directions([%{"lat" => 0, "lon" => 0}])
      {:ok, %Arrow.OpenRouteServiceAPI.DirectionsResponse{coordinates: [], segments: [], summary: %{}}}

  If anything goes wrong, then this returns an error instead.

  ## Examples
      iex> Arrow.OpenRouteServiceAPI.directions([%{"lat" => 0, "lon" => 10}, %{"lat" => 1, "lon" => 10}])
      {:error, %{type: :unknown}}
  """
  @spec directions(list()) :: {:ok, DirectionsResponse.t()} | {:error, any()}
  def directions([]), do: {:ok, %DirectionsResponse{}}
  def directions([_]), do: {:ok, %DirectionsResponse{}}

  def directions(coordinates) when is_list(coordinates) do
    request = %DirectionsRequest{
      coordinates:
        Enum.map(coordinates, fn
          %{"lat" => lat, "lon" => lon} -> [lon, lat]
        end)
    }

    case client().get_directions(request) do
      {:ok, payload} ->
        parse_directions(payload)

      {:error, error} ->
        parse_error(error)
    end
  end

  defp parse_directions(payload) do
    %{
      "features" => [
        %{
          "geometry" => %{"coordinates" => coordinates},
          "properties" => %{"segments" => segments, "summary" => summary}
        }
      ]
    } = payload

    {:ok,
     %DirectionsResponse{
       coordinates: Enum.map(coordinates, fn [lon, lat] -> %{"lat" => lat, "lon" => lon} end),
       segments:
         segments
         |> Enum.map(
           &%{
             distance: &1["distance"],
             duration: &1["duration"]
           }
         ),
       summary:
         summary
         |> List.wrap()
         |> Enum.map(
           &%{
             distance: &1["distance"],
             duration: &1["duration"]
           }
         )
         |> List.first()
     }}
  end

  # Convert API Error codes into specific errors
  # https://giscience.github.io/openrouteservice/api-reference/error-codes

  # 2010: Point was not found.
  defp parse_error(%{"code" => 2010}), do: {:error, %{type: :no_route}}

  defp parse_error(_error), do: {:error, %{type: :unknown}}

  defp client, do: Application.get_env(:arrow, Arrow.OpenRouteServiceAPI)[:client]
end
