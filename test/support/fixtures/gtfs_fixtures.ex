defmodule Arrow.GtfsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  GTFS entities.
  """

  use ExMachina.Ecto, repo: Arrow.Repo

  alias Arrow.Gtfs.{Agency, Route, Stop}
  alias Arrow.Repo

  @doc """
  Generate a GTFS stop.
  """
  def stop_fixture(attrs \\ %{}) do
    changes =
      attrs
      |> Enum.into(%{
        id: sequence(:source_label, &"gtfs-stop-#{&1}"),
        code: nil,
        name: "Test Stop",
        desc: nil,
        platform_code: nil,
        platform_name: nil,
        lat: 42.3601,
        lon: -71.0589,
        zone_id: nil,
        address: nil,
        url: nil,
        level: nil,
        location_type: :stop_platform,
        parent_station: nil,
        wheelchair_boarding: :accessible,
        municipality: "Boston",
        on_street: nil,
        at_street: nil,
        vehicle_type: :bus
      })

    {:ok, stop} =
      %Stop{}
      |> Stop.changeset(changes)
      |> Repo.insert()

    stop
  end

  @doc """
  Generate a GTFS route.
  """
  def route_fixture(attrs \\ %{}) do
    changes =
      attrs
      |> Enum.into(%{
        id: sequence(:source_label, &"gtfs-route-#{&1}"),
        agency_id: agency_fixture().id,
        short_name: nil,
        long_name: "Red Line",
        desc: "Rapid Transit",
        type: :heavy_rail,
        url: "https://www.mbta.com/schedules/Red",
        color: "DA291C",
        text_color: "FFFFFF",
        sort_order: 10010,
        fare_class: "Rapid Transit",
        listed_route: nil,
        network_id: "rapid_transit"
      })

    {:ok, route} =
      %Route{}
      |> Route.changeset(changes)
      |> Repo.insert()

    route
  end

  @doc """
  Generate a GTFS agency.
  """
  def agency_fixture(attrs \\ %{}) do
    changes =
      attrs
      |> Enum.into(%{
        id: sequence(:source_label, &"gtfs-agency-#{&1}"),
        name: "MBTA",
        url: "https://www.mbta.com",
        timezone: "ETC"
      })

    {:ok, agency} =
      %Agency{}
      |> Agency.changeset(changes)
      |> Repo.insert()

    agency
  end
end
