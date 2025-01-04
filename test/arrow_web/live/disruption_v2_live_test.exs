defmodule ArrowWeb.DisruptionV2LiveTest do
  use ArrowWeb.ConnCase

  import Phoenix.LiveViewTest
  import Arrow.DisruptionsFixtures

  @create_attrs %{
    title: "the great molasses disruption of 2025",
    mode: "commuter_rail",
    is_active: true,
    description: "Run for the hills"
  }
  @update_attrs %{title: "the second great molasses disruption"}
  @invalid_attrs %{description: nil}

  defp create_disruption_v2(_) do
    disruption_v2 = disruption_v2_fixture()
    %{disruption_v2: disruption_v2}
  end

  describe "Index" do
    @tag :authenticated_admin
    setup [:create_disruption_v2]

    test "saves new disruption_v2", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/disruptionsv2/new")

      assert index_live
             |> form("#disruption_v2-form", disruption_v2: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#disruption_v2-form", disruption_v2: @create_attrs)
             |> render_submit()

      html = render(index_live)
      assert html =~ "Disruption created successfully"
    end

    test "updates disruption_v2", %{conn: conn, disruption_v2: disruption_v2} do
      {:ok, index_live, _html} = live(conn, ~p"/disruptionsv2/#{disruption_v2.id}")

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
  end
end
