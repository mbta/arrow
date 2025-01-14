defmodule Arrow.LimitsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Arrow.Limits` context.
  """

  @doc """
  Generate a limit.
  """
  def limit_fixture(attrs \\ %{}) do
    {:ok, limit} =
      attrs
      |> Enum.into(%{
        end_date: ~U[2025-01-08 13:44:00Z],
        start_date: ~U[2025-01-08 13:44:00Z]
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
        day_name: "some day_name",
        end_time: ~T[14:00:00],
        start_time: ~T[14:00:00]
      })
      |> Arrow.Limits.create_limit_day_of_week()

    limit_day_of_week
  end
end
