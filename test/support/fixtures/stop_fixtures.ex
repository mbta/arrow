defmodule Arrow.StopsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Arrow.Stops` context.
  """

  @doc """
  Generate a stop.
  """
  def stop_fixture(attrs \\ %{}) do
    {:ok, stop} =
      attrs
      |> Enum.into(%{
        at_street: "some at_street",
        level_id: "some level_id",
        municipality: "some municipality",
        on_street: "some on_street",
        parent_station: "some parent_station",
        platform_code: "some platform_code",
        platform_name: "some platform_name",
        stop_address: "some stop_address",
        stop_desc: "some stop_desc",
        stop_id: Ecto.UUID.generate(),
        stop_lat: 120.5,
        stop_lon: 120.5,
        stop_name: "some stop_name",
        zone_id: "some zone_id"
      })
      |> Arrow.Stops.create_stop()

    stop
  end
end
