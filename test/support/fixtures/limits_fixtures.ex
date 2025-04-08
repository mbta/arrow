defmodule Arrow.LimitsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Arrow.Limits` context.
  """

  import Arrow.Factory

  @doc """
  Generate a limit.
  """
  def limit_fixture(attrs \\ %{}) do
    start_stop = insert(:gtfs_stop)
    end_stop = insert(:gtfs_stop)
    route = insert(:gtfs_route)

    {:ok, limit} =
      attrs
      |> Enum.into(%{
        end_date: ~D[2025-01-09],
        start_date: ~D[2025-01-08],
        start_stop_id: start_stop.id,
        end_stop_id: end_stop.id,
        route_id: route.id,
        limit_day_of_weeks: [
          %{active?: true, day_name: :friday, start_time: "14:00", end_time: "15:00"}
        ]
      })
      |> Arrow.Limits.create_limit()

    limit
  end

  @doc """
  Generate a limit_day_of_week.
  """
  def limit_day_of_week_fixture(attrs \\ %{}) do
    {:ok, limit_day_of_week} =
      attrs
      |> Enum.into(%{
        active?: true,
        day_name: :monday,
        end_time: "15:00",
        start_time: "14:00"
      })
      |> Arrow.Limits.create_limit_day_of_week()

    limit_day_of_week
  end
end
