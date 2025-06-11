defmodule Arrow.GeoTest do
  use ExUnit.Case

  alias Arrow.Geo

  describe "haversine_distance/2" do
    test "calculates distance between two points correctly" do
      # Duck Island
      point1 = {42.354803347033396, -71.07019472211407}
      # Boston Common Frog Pond
      point2 = {42.35618379265039, -71.06580229267753}

      distance = Geo.haversine_distance(point1, point2)

      # Just over 392 meters
      assert_in_delta distance, 392, 1
    end

    test "returns 0 for same point" do
      point = {42.3554, -71.0655}

      assert Geo.haversine_distance(point, point) == 0.0
    end
  end

  describe "distance_from_point_to_shape/2" do
    test "calculates minimum distance to a polyline" do
      # Duck Island
      point = {42.35473610465532, -71.0702171107139}

      shape = [
        # George Washington Statue
        [42.35390664762593, -71.0709438695908],
        # Bagheera Fountain
        [42.35417999884335, -71.06916656721984],
        # Garden Flagpole
        [42.35365329665548, -71.06866134421084]
      ]

      distance = Geo.distance_from_point_to_shape(point, shape)

      assert_in_delta distance, 78, 1
    end
  end

  describe "distance_to_segment/3" do
    test "calculates distance to segment correctly" do
      # Duck Island
      point = {42.35473610465532, -71.0702171107139}

      # George Washington Statue
      start_point = {42.35390664762593, -71.0709438695908}
      # Bagheera Fountain
      end_point = {42.35417999884335, -71.06916656721984}

      distance = Geo.distance_to_segment(point, start_point, end_point)

      assert_in_delta distance, 78, 1
    end

    test "handles point segment (start == end)" do
      point = {42.3550, -71.0660}
      segment_point = {42.3554, -71.0655}

      distance = Geo.distance_to_segment(point, segment_point, segment_point)

      assert distance == Geo.haversine_distance(point, segment_point)
    end
  end
end
