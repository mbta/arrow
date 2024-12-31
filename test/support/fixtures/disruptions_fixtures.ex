defmodule Arrow.DisruptionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Arrow.Disruptions` context.
  """

  @doc """
  Generate a disruption_v2.
  """
  def disruption_v2_fixture(attrs \\ %{}) do
    {:ok, disruption_v2} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Arrow.Disruptions.create_disruption_v2()

    disruption_v2
  end
end
