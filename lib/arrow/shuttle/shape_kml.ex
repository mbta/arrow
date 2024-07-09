defmodule Arrow.Shuttle.ShapeKML do
  defstruct [:name, :coordinates]
end

defimpl Saxy.Builder, for: Arrow.Shuttle.ShapeKML do
  import Saxy.XML

  def build(%{name: name, coordinates: coordinates}) do
    element(
      "Placemark",
      [],
      [
        element("name", [], name),
        element("LineString", [], element("coordinates", [], coordinates))
      ]
    )
  end
end
