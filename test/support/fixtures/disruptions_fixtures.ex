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
        title: "get disrupted bro",
        mode: "subway",
        is_active: true,
        description: "very disruptive",
        limits: [],
        replacement_services: []
      })
      |> Arrow.Disruptions.create_disruption_v2()

    disruption_v2
  end
end
