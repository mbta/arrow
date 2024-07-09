defmodule Arrow.Shuttle.KML do
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
