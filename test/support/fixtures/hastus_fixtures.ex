defmodule Arrow.HastusFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Arrow.Hastus` context.
  """

  @preloads [:line, :disruption, :trip_route_directions, services: [:service_dates]]

  @doc """
  Generate a export.
  """
  def export_fixture(attrs \\ %{}) do
    {:ok, export} =
      attrs
      |> Enum.into(%{
        s3_path: "s3://mbta-arrow/test/hastus-export-uploads/export.zip",
        services: [
          %{
            name: "some-Weekday-service",
            service_dates: [%{start_date: ~D[2025-01-01], end_date: ~D[2025-01-10]}],
            import?: true
          }
        ]
      })
      |> Arrow.Hastus.create_export()

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
      |> Arrow.Hastus.create_service()

    service
  end

  @doc """
  Generate a service_date.
  """
  def service_date_fixture(attrs \\ %{}) do
    {:ok, service_date} =
      attrs
      |> Enum.into(%{
        end_date: ~D[2025-03-11],
        start_date: ~D[2025-03-11]
      })
      |> Arrow.Hastus.create_service_date()

    service_date
  end
end
