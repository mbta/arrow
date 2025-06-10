defmodule Arrow.HastusFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Arrow.Hastus` context.
  """

  import Arrow.Factory

  @preloads [
    :line,
    :disruption,
    :trip_route_directions,
    services: [:service_dates, derived_limits: [:start_stop, :end_stop]]
  ]

  @doc """
  Generate a export.
  """
  def export_fixture(attrs \\ %{}) do
    start_stop = insert(:gtfs_stop)
    end_stop = insert(:gtfs_stop)

    {:ok, export} =
      attrs
      |> Enum.into(%{
        s3_path: "s3://mbta-arrow/test/hastus-export-uploads/export.zip",
        services: [
          %{
            name: "some-Weekday-service",
            service_dates: [%{start_date: ~D[2025-01-01], end_date: ~D[2025-01-10]}],
            import?: true,
            derived_limits: [%{start_stop_id: start_stop.id, end_stop_id: end_stop.id}]
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
