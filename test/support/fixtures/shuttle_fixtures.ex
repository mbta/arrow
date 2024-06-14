defmodule Arrow.ShuttleFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Arrow.Shuttle` context.
  """

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
        name: unique_shape_name()
      })
      |> Arrow.Shuttle.create_shape()

    shape
  end
end
