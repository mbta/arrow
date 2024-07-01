defmodule ArrowWeb.ShapeControllerTest do
  use ArrowWeb.ConnCase, async: true

  import Arrow.ShuttleFixtures

  @create_attrs %{
    name: "some name",
    filename: %Plug.Upload{
      path: "test/support/fixtures/kml/one_shape.kml",
      filename: "some filename"
    }
  }
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{
    name: nil,
    filename: %Plug.Upload{
      path: "test/support/fixtures/kml/invalid_file.kml",
      filename: "invalid_file.kml"
    }
  }
  @file_read_fail_attrs %{
    name: nil,
    filename: %Plug.Upload{
      path: "file_doesnt_exist_for_some_reason",
      filename: "some_file.kml"
    }
  }

  describe "index" do
    @tag :authenticated_admin
    test "lists all shapes", %{conn: conn} do
      conn = get(conn, ~p"/shapes")
      assert html_response(conn, 200) =~ "Listing Shapes"
    end
  end

  describe "new shape" do
    @tag :authenticated_admin
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/shapes_upload")
      assert html_response(conn, 200) =~ "New Shapes"
    end
  end

  describe "create shape" do
    @tag :authenticated_admin
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/shapes_upload", shape_upload: @create_attrs)

      assert redirected_to(conn) == ~p"/shapes/"

      conn = ArrowWeb.ConnCase.authenticated_admin()
      conn = get(conn, ~p"/shapes")
      # Currently uses the name from the kml file
      assert html_response(conn, 200) =~ "RL: Alewife - Harvard - Via Brattle St - Harvard"
    end

    @tag :authenticated_admin
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/shapes_upload", shape_upload: @invalid_attrs)
      assert html_response(conn, 200) =~ "Failed to upload shapes from invalid_file.kml"
      assert html_response(conn, 200) =~ "xml was invalid"
      assert html_response(conn, 200) =~ "unexpected end of input, expected token:"
      assert html_response(conn, 200) =~ "New Shapes"
    end

    @tag :authenticated_admin
    test "renders errors when file read fails", %{conn: conn} do
      conn = post(conn, ~p"/shapes_upload", shape_upload: @file_read_fail_attrs)
      assert html_response(conn, 200) =~ "Failed to upload shapes from some_file.kml"
      assert html_response(conn, 200) =~ "no such file or directory"
      assert html_response(conn, 200) =~ "New Shapes"
    end
  end

  describe "edit shape" do
    setup [:create_shape]

    @tag :authenticated_admin
    test "renders form for editing chosen shape", %{conn: conn, shape: shape} do
      conn = get(conn, ~p"/shapes/#{shape}/edit")
      assert html_response(conn, 200) =~ "Edit Shape"
    end
  end

  describe "update shape" do
    setup [:create_shape]

    @tag :authenticated_admin
    test "redirects when data is valid", %{conn: conn, shape: shape} do
      conn = put(conn, ~p"/shapes/#{shape}", shape: @update_attrs)
      assert redirected_to(conn) == ~p"/shapes/#{shape}"

      conn = ArrowWeb.ConnCase.authenticated_admin()
      conn = get(conn, ~p"/shapes/#{shape}")
      assert html_response(conn, 200) =~ "some updated name"
    end

    @tag :authenticated_admin
    test "renders errors when data is invalid", %{conn: conn, shape: shape} do
      conn = put(conn, ~p"/shapes/#{shape}", shape: @invalid_attrs)
      assert html_response(conn, 200) =~ "Oops, something went wrong!"
      assert html_response(conn, 200) =~ "Edit Shape"
    end
  end

  describe "delete shape" do
    setup [:create_shape]

    @tag :authenticated_admin
    test "deletes chosen shape", %{conn: conn, shape: shape} do
      conn = delete(conn, ~p"/shapes/#{shape}")
      assert redirected_to(conn) == ~p"/shapes"

      conn = ArrowWeb.ConnCase.authenticated_admin()

      assert_error_sent 404, fn ->
        get(conn, ~p"/shapes/#{shape}")
      end
    end
  end

  defp create_shape(_) do
    shape = shape_fixture()
    %{shape: shape}
  end
end
