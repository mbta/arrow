defmodule Arrow.HastusFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Arrow.Hastus` context.
  """

  @doc """
  Generate a export.
  """
  def export_fixture(attrs \\ %{}) do
    {:ok, export} =
      attrs
      |> Enum.into(%{
        s3_path: "some s3_path"
      })
      |> Arrow.Hastus.create_export()

    export
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
        end_date: ~U[2025-03-11 17:17:00Z],
        start_date: ~U[2025-03-11 17:17:00Z]
      })
      |> Arrow.Hastus.create_service_date()

    service_date
  end
end
