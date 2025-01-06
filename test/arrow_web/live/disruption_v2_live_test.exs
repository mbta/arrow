defmodule ArrowWeb.DisruptionV2LiveTest do
  use ArrowWeb.ConnCase

  import Phoenix.LiveViewTest
  import Arrow.DisruptionsFixtures

  @create_attrs %{
    title: "the great molasses disruption of 2025",
    mode: "commuter_rail",
    is_active: true,
    description: nil
  }
  @update_attrs %{
    title: "the second great molasses disruption",
    mode: "subway",
    is_active: false,
    description: "there is more"
  }
  @invalid_attrs %{
    title: nil,
    mode: "silver_line",
    is_active: true,
    description: "foobar"
  }

  defp create_disruption_v2(_) do
    disruption_v2 = disruption_v2_fixture()
    %{disruption_v2: disruption_v2}
  end

  describe "Changing Disruptions" do
    @tag :authenticated_admin
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

    @tag :authenticated_admin
    setup [:create_disruption_v2]

    test "updates disruption_v2", %{conn: conn, disruption_v2: disruption_v2} do
      {:ok, index_live, _html} = live(conn, ~p"/disruptionsv2/#{disruption_v2.id}/edit")

      assert index_live
             |> form("#disruption_v2-form", disruption_v2: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#disruption_v2-form", disruption_v2: @update_attrs)
             |> render_submit()

      html = render(index_live)
      assert html =~ "Disruption edited successfully"
    end
  end
end
