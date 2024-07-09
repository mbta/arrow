defmodule Arrow.Shuttle.KML do
  @moduledoc """
  A struct for the full KML representation of a shape to be used with Saxy.Builder
  """
  @derive {Saxy.Builder,
           name: "kml", attributes: [:xmlns], children: [Folder: &__MODULE__.build_shape/1]}

  import Saxy.XML

  defstruct [:xmlns, :Folder]

  def build_shape(%{name: name, coordinates: coordinates}) do
    element(
      "Folder",
      [],
      Saxy.Builder.build(%Arrow.Shuttle.ShapeKML{name: name, coordinates: coordinates})
    )
  end
end
