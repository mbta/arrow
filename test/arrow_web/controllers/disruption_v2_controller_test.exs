defmodule ArrowWeb.DisruptionV2ControllerTest do
  use ArrowWeb.ConnCase

  import Arrow.Factory

  describe "index/2" do
    @tag :authenticated
    test "lists disruptions", %{conn: conn} do
      insert(:limit,
        disruption: build(:disruption_v2, title: "Test disruption"),
        route: build(:gtfs_route, id: "Red")
      )

      resp = conn |> get(~p"/disruptionsv2") |> html_response(200)

      assert resp =~ "Test disruption"
    end

    @tag :authenticated
    test "lists disruptions that match a filter", %{conn: conn} do
      insert(:limit,
        disruption: build(:disruption_v2, title: "Test disruption"),
        route: build(:gtfs_route, id: "Red")
      )

      resp = conn |> get(~p"/disruptionsv2?kinds[]=red_line") |> html_response(200)

      assert resp =~ "Test disruption"
    end

    @tag :authenticated
    test "doesn't list disruptions that don't match a filter", %{conn: conn} do
      insert(:limit,
        disruption: build(:disruption_v2, title: "Test disruption"),
        route: build(:gtfs_route, id: "Red")
      )

      resp = conn |> get(~p"/disruptionsv2?kinds[]=orange_line") |> html_response(200)

      refute resp =~ "Test disruption"
    end
  end
end
