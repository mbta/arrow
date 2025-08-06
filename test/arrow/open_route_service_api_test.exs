defmodule Arrow.OpenRouteServiceAPITest do
  use ExUnit.Case, async: false

  import Arrow.Factory
  import Mox

  alias Arrow.OpenRouteServiceAPI.DirectionsRequest
  alias Arrow.OpenRouteServiceAPI.DirectionsResponse
  alias Arrow.OpenRouteServiceAPI.MockClient

  setup do
    stub(
      MockClient,
      :get_directions,
      fn
        %DirectionsRequest{
          coordinates: [
            [0, 0],
            [1, 0]
          ]
        } ->
          {:ok,
           %{
             "features" => [
               %{
                 "geometry" => %{
                   "coordinates" => [
                     [0, 0],
                     [0.1, 0.5],
                     [0, 1]
                   ]
                 },
                 "properties" => %{
                   "segments" => [
                     %{
                       "duration" => 100,
                       "distance" => 0.1
                     },
                     %{
                       "duration" => 100,
                       "distance" => 0.2
                     },
                     %{
                       "duration" => 100,
                       "distance" => 0.3
                     }
                   ],
                   "summary" => %{
                     "duration" => 300,
                     "distance" => 0.5
                   }
                 }
               }
             ]
           }}

        %DirectionsRequest{
          coordinates: [[10, 0], [10, 1]]
        } ->
          {:error, %{"message" => "Invalid API Key"}}
      end
    )

    :ok
  end

  doctest Arrow.OpenRouteServiceAPI

  test "parses directions" do
    expect(
      MockClient,
      :get_directions,
      fn _ ->
        {:ok,
         build(:ors_directions_json,
           segments: [
             %{
               "duration" => 100,
               "distance" => 0.20
             },
             %{
               "duration" => 100,
               "distance" => 0.20
             },
             %{
               "duration" => 100,
               "distance" => 0.30
             }
           ]
         )}
      end
    )

    assert {:ok,
            %DirectionsResponse{
              segments: [
                %{distance: 0.20, duration: 100},
                %{distance: 0.20, duration: 100},
                %{distance: 0.30, duration: 100}
              ],
              summary: %{distance: 0.7, duration: 300}
            }} =
             Arrow.OpenRouteServiceAPI.directions([
               %{"lat" => 0, "lon" => 0},
               %{"lat" => 0, "lon" => 1}
             ])
  end

  test "unknown errors from ORS return `type: :unknown`" do
    expect(
      MockClient,
      :get_directions,
      fn _ ->
        {:error, %{"code" => -1}}
      end
    )

    assert {:error, %{type: :unknown}} =
             Arrow.OpenRouteServiceAPI.directions([
               %{"lat" => 0, "lon" => 0},
               %{"lat" => 0, "lon" => 1}
             ])
  end

  test "point not found errors from ORS return `type: :no_route`" do
    expect(
      MockClient,
      :get_directions,
      fn _ ->
        {:error, %{"code" => 2010}}
      end
    )

    assert {:error, %{type: :no_route}} =
             Arrow.OpenRouteServiceAPI.directions([
               %{"lat" => 0, "lon" => 0},
               %{"lat" => 0, "lon" => 1}
             ])
  end

  test "route not found errors from ORS return `type: :no_route`" do
    expect(
      MockClient,
      :get_directions,
      fn _ ->
        {:error, %{"code" => 2009}}
      end
    )

    assert {:error, %{type: :no_route}} =
             Arrow.OpenRouteServiceAPI.directions([
               %{"lat" => 0, "lon" => 0},
               %{"lat" => 0, "lon" => 1}
             ])
  end
end
