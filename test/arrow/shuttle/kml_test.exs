defmodule Arrow.Shuttle.KMLTest do
  @moduledoc false
  use Arrow.DataCase

  @required_struct %Arrow.Shuttle.ShapeKML{
    name: "some shape",
    coordinates: "-71.14163,42.39551 -71.14163,42.39551 -71.14163,42.39551"
  }

  describe "build" do
    test "builds the expected Saxy format" do
      assert {"kml", [{"xmlns", "http://www.opengis.net/kml/2.2"}],
              [
                {"Folder", [],
                 [
                   {"Placemark", [],
                    [
                      {"name", [], ["some shape"]},
                      {"LineString", [],
                       [
                         {"coordinates", [],
                          ["-71.14163,42.39551 -71.14163,42.39551 -71.14163,42.39551"]}
                       ]}
                    ]}
                 ]}
              ]} =
               Saxy.Builder.build(%Arrow.Shuttle.KML{
                 xmlns: "http://www.opengis.net/kml/2.2",
                 Folder: @required_struct
               })
    end
  end
end
