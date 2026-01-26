defmodule Arrow.TrainsformerFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Arrow.Trainsformer` context.
  """

  @preloads [
    :disruption,
    services: [:service_dates]
  ]

  @doc """
  Generate a export.
  """
  def export_fixture(attrs \\ %{}) do
    {:ok, export} =
      attrs
      |> Enum.into(%{
        s3_path: "s3://mbta-arrow/test/trainsformer-export-uploads/export.zip",
        routes: [%{route_id: "CR-Worcester"}],
        services: [
          %{
            name: "SPRING2025-SOUTHSS-Weekend-31A",
            service_dates: [
              %{
                "service_date_days_of_week" => ["monday"],
                "start_date" => "2026-01-26",
                "end_date" => "2026-01-26"
              }
            ]
          }
        ]
      })
      |> Arrow.Trainsformer.create_export()

    Arrow.Repo.preload(export, @preloads)
  end

  @doc """
  Generate a service.
  """
  def service_fixture(attrs \\ %{}) do
    {:ok, service} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Arrow.Trainsformer.create_service()

    service
  end

  @doc """
  Generate a service_date.
  """
  def service_date_fixture(attrs \\ %{}) do
    {:ok, service_date} =
      attrs
      |> Enum.into(%{
        "service_date_days_of_week" => ["monday"],
        "start_date" => "2026-01-26",
        "end_date" => "2026-01-26"
      })
      |> Arrow.Trainsformer.create_service_date()

    service_date
  end
end
