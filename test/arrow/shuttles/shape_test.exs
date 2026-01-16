defmodule Arrow.Shuttles.ShapeTest do
  use Arrow.DataCase

  alias Arrow.Shuttles.Shape

  describe "changeset/2" do
    test "validates shape name ends with -S" do
      changeset =
        Shape.changeset(%Shape{}, %{name: "foo", path: "path", bucket: "bucket", prefix: "prefix"})

      assert {"must end with -S", _} = changeset.errors[:name]
    end
  end
end
