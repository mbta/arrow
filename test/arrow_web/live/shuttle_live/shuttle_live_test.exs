defmodule ArrowWeb.ShuttleLiveTest do
  use ArrowWeb.ConnCase

  import Phoenix.LiveViewTest
  import Arrow.ShuttlesFixtures

  @create_attrs %{
    disrupted_route_id: "",
    routes: %{
      "0" => %{
        :_persistent_id => "0",
        destination: "Broadway",
        direction_desc: "Southbound",
        direction_id: "0",
        shape_id: "",
        suffix: "",
        waypoint: ""
      },
      "1" => %{
        :_persistent_id => "1",
        destination: "Harvard",
        direction_desc: "Northbound",
        direction_id: "1",
        shape_id: "",
        suffix: "",
        waypoint: ""
      }
    },
    shuttle_name: "Blah",
    status: "draft"
  }

  @update_attrs %{
    disrupted_route_id: "",
    routes: %{
      "0" => %{
        :_persistent_id => "0",
        destination: "Broadway",
        direction_desc: "Southbound",
        direction_id: "0",
        shape_id: "",
        suffix: "",
        waypoint: ""
      },
      "1" => %{
        :_persistent_id => "1",
        destination: "Harvard",
        direction_desc: "Northbound",
        direction_id: "1",
        shape_id: "",
        suffix: "",
        waypoint: ""
      }
    },
    shuttle_name: "Meh",
    status: "draft"
  }

  @invalid_attrs %{
    disrupted_route_id: "",
    shuttle_name: nil,
    status: "draft"
  }

  describe "new shuttle" do
    @tag :authenticated_admin
    test "renders form", %{conn: conn} do
      {:ok, _new_live, html} = live(conn, ~p"/shuttles/new")
      assert html =~ "create new replacement service shuttle"
    end
  end

  describe "create shuttle" do
    @tag :authenticated_admin
    test "redirects to new shuttle when data is valid", %{conn: conn} do
      {:ok, new_live, _html} = live(conn, ~p"/shuttles/new")

      {:ok, conn} =
        new_live
        |> form("#shuttle-form", shuttle: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn)

      assert html_response(conn, 200) =~ ~r/shuttle created successfully/i

      assert %{"id" => _id} = conn.params
    end

    @tag :authenticated_admin
    test "renders errors when data is invalid", %{conn: conn} do
      {:ok, new_live, _html} = live(conn, ~p"/shuttles/new")

      assert new_live |> form("#shuttle-form", shuttle: @invalid_attrs) |> render_submit() =~
               "can&#39;t be blank"
    end
  end

  describe "edit shuttle" do
    setup [:create_shuttle]

    @tag :authenticated_admin
    test "redirects to updated shuttle when data is valid", %{conn: conn, shuttle: shuttle} do
      {:ok, edit_live, _html} = live(conn, ~p"/shuttles/#{shuttle}/edit")

      {:ok, conn} =
        edit_live
        |> form("#shuttle-form", shuttle: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn)

      assert html_response(conn, 200) =~ ~r/shuttle updated successfully/i
    end

    @tag :authenticated_admin
    test "renders errors when data is invalid", %{conn: conn, shuttle: shuttle} do
      {:ok, new_live, _html} = live(conn, ~p"/shuttles/#{shuttle}/edit")

      assert new_live |> form("#shuttle-form", shuttle: @invalid_attrs) |> render_submit() =~
               "can&#39;t be blank"
    end
  end

  defp create_shuttle(_) do
    shuttle = shuttle_fixture()
    %{shuttle: shuttle}
  end
end
