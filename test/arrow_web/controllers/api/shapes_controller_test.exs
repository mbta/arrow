defmodule ArrowWeb.API.ShapesControllerTest do
  use ArrowWeb.ConnCase

  import Arrow.ShuttlesFixtures
  import Test.Support.Helpers

  describe "index/2" do
    @tag :authenticated_admin
    test "includes all shapes", %{conn: conn} do
      shape1 = s3_mocked_shape_fixture(%{name: "shape1-S"})
      shape2 = s3_mocked_shape_fixture(%{name: "shape2-S"})
      shape3 = s3_mocked_shape_fixture(%{name: "shape3-S"})

      res = json_response(get(conn, "/api/shapes"), 200)

      assert %{
               "data" => data,
               "jsonapi" => %{"version" => "1.0"}
             } = res

      assert Enum.count(data) == 3

      shape_ids = MapSet.new(data, fn %{"id" => id} -> String.to_integer(id) end)
      assert shape_ids == MapSet.new([shape1.id, shape2.id, shape3.id])
    end

    @tag :authenticated_admin
    test "includes download_url field for each shape", %{conn: conn} do
      reassign_env(:shape_storage_enabled?, true)

      _shape =
        s3_mocked_shape_fixture(%{
          name: "TestToStation-S",
          bucket: "test-bucket",
          path: "shapes/TestToStation-S.kml",
          prefix: "shapes/"
        })

      res = json_response(get(conn, "/api/shapes"), 200)

      assert %{"data" => [shape_data]} = res

      assert %{
               "attributes" => %{
                 "download_url" => download_url,
                 "name" => "TestToStation-S",
                 "bucket" => "test-bucket",
                 "path" => "shapes/TestToStation-S.kml",
                 "prefix" => "shapes/"
               }
             } = shape_data

      assert String.contains?(download_url, "s3.amazonaws.com")
      assert String.contains?(download_url, "test-bucket")
      assert String.contains?(download_url, "TestToStation-S.kml")
    end
  end
end
