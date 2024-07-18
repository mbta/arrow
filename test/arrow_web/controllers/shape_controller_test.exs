defmodule ArrowWeb.ShapeControllerTest do
  use ArrowWeb.ConnCase, async: true
  alias Arrow.Repo
  alias Arrow.Shuttle.Shape

  import Arrow.ShuttleFixtures

  @upload_attrs %{
    name: "some name",
    filename: %Plug.Upload{
      path: "test/support/fixtures/kml/one_shape.kml",
      filename: "some filename"
    }
  }
  @bulk_upload_attrs %{
    name: nil,
    filename: %Plug.Upload{
      path: "test/support/fixtures/kml/multiple_shapes.kml",
      filename: "multiple_shapes.kml"
    }
  }
  @invalid_upload_attrs %{
    name: nil,
    filename: %Plug.Upload{
      path: "test/support/fixtures/kml/invalid_file.kml",
      filename: "invalid_file.kml"
    }
  }
  @invalid_whitespace_attrs %{
    name: nil,
    filename: %Plug.Upload{
      path: "test/support/fixtures/kml/invalid_whitespace_shape.kml",
      filename: "invalid_whitespace_shape.kml"
    }
  }
  @file_read_fail_attrs %{
    name: nil,
    filename: %Plug.Upload{
      path: "file_doesnt_exist_for_some_reason",
      filename: "some_file.kml"
    }
  }

  @create_attrs [
    {0,
     %{
       name: "some other name",
       save: "false",
       coordinates: "-71.14163,42.39551 -71.14163,42.39551 -71.14163,42.39551"
     }},
    {1, %{name: "some name", save: "true", coordinates: "-71.14163,42.39551 -71.14163,42.39551 "}}
  ]

  describe "index" do
    @tag :authenticated_admin
    test "lists all shapes", %{conn: conn} do
      conn = get(conn, ~p"/shapes")
      assert html_response(conn, 200) =~ "Listing Shapes"
      refute html_response(conn, 200) =~ "Components.ShapeViewMap"
    end
  end

  describe "new shape" do
    @tag :authenticated_admin
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/shapes_upload")
      assert html_response(conn, 200) =~ "New Shapes"
      assert html_response(conn, 200) =~ "Components.ShapeViewMap"
    end
  end

  describe "download shape" do
    @tag :authenticated_admin
    test "redirects to s3 url", %{conn: conn} do
      uuid = Ecto.UUID.generate()
      prefix = "arrow/test-runner/#{uuid}/"
      Application.put_env(:arrow, :shape_storage_prefix, prefix)

      # Create valid shape:
      conn = post(conn, ~p"/shapes_upload", shapes: @create_attrs)

      assert redirected_to(conn) == ~p"/shapes/"

      %{id: id} = Repo.get_by(Shape, name: "some name")

      # Attempt to download:
      conn = ArrowWeb.ConnCase.authenticated_admin()
      conn = get(conn, ~p"/shapes/#{id}/download")

      assert redirected_to(conn, 302) ==
               "https://disabled.s3.amazonaws.com/disabled"
    end
  end

  describe "download shape" do
    @tag :authenticated_admin
    test "redirects to s3 url", %{conn: conn} do
      uuid = Ecto.UUID.generate()
      prefix = "arrow/test-runner/#{uuid}/"
      Application.put_env(:arrow, :shape_storage_prefix, prefix)

      # Create valid shape:
      conn = post(conn, ~p"/shapes_upload", shapes: @create_attrs)

      assert redirected_to(conn) == ~p"/shapes/"

      %{id: id} = Repo.get_by(Shape, name: "some name")

      # Attempt to download:
      conn = ArrowWeb.ConnCase.authenticated_admin()
      conn = get(conn, ~p"/shapes/#{id}/download")

      assert redirected_to(conn, 302) ==
               "https://disabled.s3.amazonaws.com/disabled"
    end
  end

  describe "shapes_upload for create" do
    @tag :authenticated_admin
    test "redirects to select when upload file is valid with one shape", %{conn: conn} do
      conn = post(conn, ~p"/shapes_upload", shapes_upload: @upload_attrs)
      assert html_response(conn, 200) =~ "Successfully parsed shapes"
      assert html_response(conn, 200) =~ "RL: Alewife - Harvard - Via Brattle St - Harvard"
      assert html_response(conn, 200) =~ "Shapes from File"
      assert html_response(conn, 200) =~ "Components.ShapeViewMap"
    end

    @tag :authenticated_admin
    test "redirects to select when upload file is valid with many shapes", %{conn: conn} do
      conn = post(conn, ~p"/shapes_upload", shapes_upload: @bulk_upload_attrs)
      assert html_response(conn, 200) =~ "Successfully parsed shapes"
      assert html_response(conn, 200) =~ "RL: JFK/UMass - Andrew - JFK/UMASS"
      assert html_response(conn, 200) =~ "Shapes from File"
      assert html_response(conn, 200) =~ "Components.ShapeViewMap"
    end

    @tag :authenticated_admin
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/shapes_upload", shapes_upload: @invalid_upload_attrs)
      assert html_response(conn, 200) =~ "Failed to upload shapes from invalid_file.kml"
      assert html_response(conn, 200) =~ "xml was invalid"
      assert html_response(conn, 200) =~ "unexpected end of input, expected token:"
      assert html_response(conn, 200) =~ "New Shapes"
      assert html_response(conn, 200) =~ "Components.ShapeViewMap"
    end

    @tag :authenticated_admin
    test "renders errors when data is invalid due to invalid whitespace in XML", %{conn: conn} do
      conn = post(conn, ~p"/shapes_upload", shapes_upload: @invalid_whitespace_attrs)

      assert html_response(conn, 200) =~
               "Failed to parse shape from kml, no coordinates were found."

      assert html_response(conn, 200) =~ "Check your whitespace."
      assert html_response(conn, 200) =~ "New Shapes"
      assert html_response(conn, 200) =~ "Components.ShapeViewMap"
    end

    @tag :authenticated_admin
    test "renders errors when data is invalid due to invalid whitespace in XML", %{conn: conn} do
      conn = post(conn, ~p"/shapes_upload", shapes_upload: @invalid_whitespace_attrs)

      assert html_response(conn, 200) =~
               "Failed to parse shape from kml, no coordinates were found."

      assert html_response(conn, 200) =~ "Check your whitespace."
      assert html_response(conn, 200) =~ "New Shapes"
    end

    @tag :authenticated_admin
    test "renders errors when file read fails", %{conn: conn} do
      conn = post(conn, ~p"/shapes_upload", shapes_upload: @file_read_fail_attrs)
      assert html_response(conn, 200) =~ "Failed to upload shapes from some_file.kml"
      assert html_response(conn, 200) =~ "no such file or directory"
      assert html_response(conn, 200) =~ "New Shapes"
      assert html_response(conn, 200) =~ "Components.ShapeViewMap"
    end
  end

  describe "create shapes" do
    @tag :authenticated_admin
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/shapes_upload", shapes: @create_attrs)

      assert redirected_to(conn) == ~p"/shapes/"

      conn = ArrowWeb.ConnCase.authenticated_admin()
      conn = get(conn, ~p"/shapes")
      assert html_response(conn, 200) =~ "some name"
      refute html_response(conn, 200) =~ "some other name"
      refute html_response(conn, 200) =~ "Components.ShapeViewMap"
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
