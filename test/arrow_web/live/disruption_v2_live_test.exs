defmodule ArrowWeb.DisruptionV2LiveTest do
  use ArrowWeb.ConnCase

  import Phoenix.LiveViewTest
  import Arrow.DisruptionsFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_disruption_v2(_) do
    disruption_v2 = disruption_v2_fixture()
    %{disruption_v2: disruption_v2}
  end

  describe "Index" do
    setup [:create_disruption_v2]

    test "lists all disruptionsv2", %{conn: conn, disruption_v2: disruption_v2} do
      {:ok, _index_live, html} = live(conn, ~p"/disruptionsv2")

      assert html =~ "Listing Disruptionsv2"
      assert html =~ disruption_v2.name
    end

    test "saves new disruption_v2", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/disruptionsv2")

      assert index_live |> element("a", "New Disruption v2") |> render_click() =~
               "New Disruption v2"

      assert_patch(index_live, ~p"/disruptionsv2/new")

      assert index_live
             |> form("#disruption_v2-form", disruption_v2: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#disruption_v2-form", disruption_v2: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/disruptionsv2")

      html = render(index_live)
      assert html =~ "Disruption v2 created successfully"
      assert html =~ "some name"
    end

    test "updates disruption_v2 in listing", %{conn: conn, disruption_v2: disruption_v2} do
      {:ok, index_live, _html} = live(conn, ~p"/disruptionsv2")

      assert index_live |> element("#disruptionsv2-#{disruption_v2.id} a", "Edit") |> render_click() =~
               "Edit Disruption v2"

      assert_patch(index_live, ~p"/disruptionsv2/#{disruption_v2}/edit")

      assert index_live
             |> form("#disruption_v2-form", disruption_v2: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#disruption_v2-form", disruption_v2: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/disruptionsv2")

      html = render(index_live)
      assert html =~ "Disruption v2 updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes disruption_v2 in listing", %{conn: conn, disruption_v2: disruption_v2} do
      {:ok, index_live, _html} = live(conn, ~p"/disruptionsv2")

      assert index_live |> element("#disruptionsv2-#{disruption_v2.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#disruptionsv2-#{disruption_v2.id}")
    end
  end

  describe "Show" do
    setup [:create_disruption_v2]

    test "displays disruption_v2", %{conn: conn, disruption_v2: disruption_v2} do
      {:ok, _show_live, html} = live(conn, ~p"/disruptionsv2/#{disruption_v2}")

      assert html =~ "Show Disruption v2"
      assert html =~ disruption_v2.name
    end

    test "updates disruption_v2 within modal", %{conn: conn, disruption_v2: disruption_v2} do
      {:ok, show_live, _html} = live(conn, ~p"/disruptionsv2/#{disruption_v2}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Disruption v2"

      assert_patch(show_live, ~p"/disruptionsv2/#{disruption_v2}/show/edit")

      assert show_live
             |> form("#disruption_v2-form", disruption_v2: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#disruption_v2-form", disruption_v2: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/disruptionsv2/#{disruption_v2}")

      html = render(show_live)
      assert html =~ "Disruption v2 updated successfully"
      assert html =~ "some updated name"
    end
  end
end
