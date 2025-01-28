defmodule Arrow.DisruptionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Arrow.Disruptions` context.
  """

  alias Arrow.ShuttlesFixtures

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

  @doc """
  Generate a replacement_service.
  """
  def replacement_service_fixture(attrs \\ %{}) do
    {:ok, replacement_service} =
      attrs
      |> Enum.into(%{
        end_date: ~D[2025-01-22],
        reason: "some reason",
        source_workbook_data: %{},
        source_workbook_filename: "some source_workbook_filename",
        start_date: ~D[2025-01-21],
        shuttle_id: ShuttlesFixtures.shuttle_fixture().id,
        disruption_id: disruption_v2_fixture().id
      })
      |> Arrow.Disruptions.create_replacement_service()

    replacement_service
  end
end
