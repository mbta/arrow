defmodule Arrow.Shuttles.KML do
  @moduledoc """
  A struct for the full KML representation of a shape to be used with Saxy.Builder
  """
  import Saxy.XML

  @derive {Saxy.Builder, name: "kml", attributes: [:xmlns], children: [Folder: &__MODULE__.build_shape/1]}

  defstruct [:xmlns, :Folder]

  def build_shape(%{name: name, coordinates: coordinates}) do
    element(
      "Folder",
      [],
      Saxy.Builder.build(%Arrow.Shuttles.ShapeKML{name: name, coordinates: coordinates})
    )
  end
end
