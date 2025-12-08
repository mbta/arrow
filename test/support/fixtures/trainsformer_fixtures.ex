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
        s3_path: "s3://mbta-arrow/test/trainsformer-export-uploads/export.zip"
      })
      |> Arrow.Trainsformer.create_export()

    Arrow.Repo.preload(export, @preloads)
  end
end
