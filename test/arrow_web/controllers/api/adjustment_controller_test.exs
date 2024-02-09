defmodule ArrowWeb.API.AdjustmentControllerTest do
  use ArrowWeb.ConnCase
  alias Arrow.{Adjustment, Repo}

  describe "index/2" do
    @tag :authenticated
    test "non-admin user can access the adjustments API", %{conn: conn} do
      assert %{status: 200} = get(conn, "/api/adjustments")
    end

    @tag :authenticated_admin
    test "returns 200", %{conn: conn} do
      assert %{status: 200} = get(conn, "/api/adjustments")
    end

    @tag :authenticated_admin
    test "returns all adjustments by default", %{conn: conn} do
      insert_adjusments()

      res = json_response(get(conn, "/api/adjustments"), 200)

      assert [
               %{
                 "attributes" => %{
                   "route_id" => "test_route_1",
                   "source" => "source1",
                   "source_label" => "label1"
                 },
                 "type" => "adjustment"
               },
               %{
                 "attributes" => %{
                   "route_id" => "test_route_2",
                   "source" => "source2",
                   "source_label" => "label2"
                 },
                 "type" => "adjustment"
               }
             ] = res["data"]
    end

    @tag :authenticated_admin
    test "can filter by route_id", %{conn: conn} do
      {adjustment_1, _} = insert_adjusments()

      data =
        json_response(
          get(conn, "/api/adjustments", %{"filter" => %{"route_id" => adjustment_1.route_id}}),
          200
        )["data"]

      assert Kernel.length(data) == 1
      assert List.first(data)["id"] == Integer.to_string(adjustment_1.id)
    end

    @tag :authenticated_admin
    test "can filter by source", %{conn: conn} do
      {_, adjustment_2} = insert_adjusments()

      data =
        json_response(
          get(conn, "/api/adjustments", %{"filter" => %{"source" => adjustment_2.source}}),
          200
        )["data"]

      assert Kernel.length(data) == 1
      assert List.first(data)["id"] == Integer.to_string(adjustment_2.id)
    end
  end

  defp insert_adjusments do
    {:ok, adjustment_1} =
      Repo.insert(%Adjustment{
        source: "source1",
        source_label: "label1",
        route_id: "test_route_1"
      })

    {:ok, adjustment_2} =
      Repo.insert(%Adjustment{
        source: "source2",
        source_label: "label2",
        route_id: "test_route_2"
      })

    {adjustment_1, adjustment_2}
  end
end
