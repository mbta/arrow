defmodule Arrow.ShuttleFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Arrow.Shuttle` context.
  """

  alias Arrow.Repo
  alias Arrow.Shuttle.Shape

  @doc """
  Generate valid coords
  """
  def coords,
    do: ["-71.14163,42.39551", "-71.14209,42.39643", "-71.14285,42.39624", "-71.14292,42.39623"]

  @doc """
  Generate a unique shape name.
  """
  def unique_shape_name, do: "some name#{System.unique_integer([:positive])}"

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
      |> Arrow.Shuttle.create_shape()

    shape
  end

  def s3_mocked_shape_fixture(attrs \\ %{}) do
    props =
      Map.merge(
        %{
          name: "test-show-shape",
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
end
