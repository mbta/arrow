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
end
