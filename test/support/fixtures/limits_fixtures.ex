defmodule Arrow.LimitsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Arrow.Limits` context.
  """

  alias Arrow.GtfsFixtures

  @doc """
  Generate a limit.
  """
  def limit_fixture(attrs \\ %{}) do
    {:ok, limit} =
      attrs
      |> Enum.into(%{
        end_date: ~D[2025-01-09],
        start_date: ~D[2025-01-08],
        start_stop: GtfsFixtures.stop_fixture(),
        end_stop: GtfsFixtures.stop_fixture(),
        route: GtfsFixtures.route_fixture(),
        limit_day_of_weeks: []
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
        day_name: "monday",
        end_time: ~T[15:00:00],
        start_time: ~T[14:00:00]
      })
      |> Arrow.Limits.create_limit_day_of_week()

    limit_day_of_week
  end
end
