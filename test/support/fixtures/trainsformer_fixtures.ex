defmodule Arrow.TrainsformerFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Arrow.Trainsformer` context.
  """

  @preloads [:disruption]

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
                start_date: ~D[2026-01-26],
                end_date: ~D[2026-01-26]
              }
            ]
          }
        ]
      })
      |> Arrow.Trainsformer.create_export()

    Arrow.Repo.preload(export, @preloads)
  end
end
