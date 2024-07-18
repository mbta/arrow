defmodule Arrow.Shuttle.ShapeKMLTest do
  @moduledoc false
  use Arrow.DataCase

  @required_struct %Arrow.Shuttle.ShapeKML{
    name: "some shape",
    coordinates: "-71.14163,42.39551 -71.14163,42.39551 -71.14163,42.39551"
  }

  describe "build/1" do
    test "builds the expected Saxy format for a KML shape" do
      assert {"Placemark", [],
              [
                {"name", [], ["some shape"]},
                {"LineString", [],
                 [
                   {"coordinates", [],
                    ["-71.14163,42.39551 -71.14163,42.39551 -71.14163,42.39551"]}
                 ]}
              ]} = Saxy.Builder.build(@required_struct)
    end
  end
end
