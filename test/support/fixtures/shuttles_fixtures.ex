defmodule Arrow.ShuttlesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Arrow.Shuttles` context.
  """

  @doc """
  Generate a unique shuttle shuttle_name.
  """
  def unique_shuttle_shuttle_name, do: "some shuttle_name#{System.unique_integer([:positive])}"

  @doc """
  Generate a shuttle.
  """
  def shuttle_fixture(attrs \\ %{}) do
    {:ok, shuttle} =
      attrs
      |> Enum.into(%{
        shuttle_name: unique_shuttle_shuttle_name(),
        status: :draft
      })
      |> Arrow.Shuttles.create_shuttle()

    shuttle
  end

  @doc """
  Generate a shuttle_route.
  """
  def shuttle_route_fixture(attrs \\ %{}) do
    {:ok, shuttle_route} =
      attrs
      |> Enum.into(%{
        destination: "some destination",
        direction_desc: "some direction_desc",
        direction_id: :"0",
        suffix: "some suffix",
        waypoint: "some waypoint"
      })
      |> Arrow.Shuttles.create_shuttle_route()

    shuttle_route
  end

  @doc """
  Generate a shuttle_route_stops.
  """
  def shuttle_route_stops_fixture(attrs \\ %{}) do
    {:ok, shuttle_route_stops} =
      attrs
      |> Enum.into(%{
        direction_id: :"0",
        stop_id: "some stop_id",
        stop_sequence: 42,
        time_to_next_stop: "120.5"
      })
      |> Arrow.Shuttles.create_shuttle_route_stops()

    shuttle_route_stops
  end
end
