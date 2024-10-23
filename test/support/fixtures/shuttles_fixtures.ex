defmodule Arrow.ShuttlesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Arrow.Shuttles` context.
  """

  alias Arrow.Repo
  alias Arrow.Shuttles.Shape

  @doc """
  Generate valid coords
  """
  def coords,
    do: ["-71.14163,42.39551", "-71.14209,42.39643", "-71.14285,42.39624", "-71.14292,42.39623"]

  @doc """
  Generate a unique shape name.
  """
  def unique_shape_name, do: "some name#{System.unique_integer([:positive])}-S"

  @doc """
  Generate a shape.
  """
  def shape_fixture(attrs \\ %{}) do
    {:ok, shape} =
      attrs
      |> Enum.into(%{
        name: unique_shape_name(),
        path: "some/prefix/file.kml",
        bucket: "some-mbta-bucket",
        prefix: "some/prefix/",
        coordinates: coords()
      })
      |> Arrow.Shuttles.create_shape()

    shape
  end

  def s3_mocked_shape_fixture(attrs \\ %{}) do
    props =
      Map.merge(
        %{
          name: "test-show-shape-S",
          path: "/test/prefix/test-show-shape.kml",
          bucket: "some-mbta-bucket",
          prefix: "test/prefix/"
        },
        attrs
      )

    {:ok, shape} =
      %Shape{}
      |> Shape.changeset(props)
      |> Repo.insert()

    shape
  end

  @doc """
  Generate a unique shuttle shuttle_name.
  """
  def unique_shuttle_shuttle_name, do: "some shuttle_name#{System.unique_integer([:positive])}"

  @doc """
  Generate a shuttle.
  """
  def shuttle_fixture(attrs \\ %{}) do
    {:ok, shuttle} =
      attrs
      |> Enum.into(%{
        shuttle_name: unique_shuttle_shuttle_name(),
        status: :draft,
        routes: []
      })
      |> Arrow.Shuttles.create_shuttle()

    shuttle
  end
end
