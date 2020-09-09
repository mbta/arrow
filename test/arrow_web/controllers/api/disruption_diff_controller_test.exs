defmodule ArrowWeb.API.DisruptionDiffControllerTest do
  use ArrowWeb.ConnCase
  import Arrow.Factory

  describe "index/2" do
    @tag :authenticated
    test "loads the disruption diffs", %{conn: conn} do
      d1 = insert(:disruption)
      insert(:disruption_revision, %{disruption: d1})

      d2 = insert(:disruption)
      d2r1 = insert(:disruption_revision, %{disruption: d2})

      _d2r2 =
        insert(:disruption_revision, %{
          disruption: d2,
          exceptions: [build(:exception, %{excluded_date: ~D[2020-03-31]})]
        })

      d2 |> Ecto.Changeset.change(%{ready_revision_id: d2r1.id}) |> Arrow.Repo.update!()

      d3 = insert(:disruption)
      d3r1 = insert(:disruption_revision, %{disruption: d3})
      d3 |> Ecto.Changeset.change(%{ready_revision_id: d3r1.id}) |> Arrow.Repo.update!()

      res = json_response(get(conn, "/api/disruption_diffs"), 200)

      assert %{
               "data" => data,
               "included" => included,
               "jsonapi" => %{"version" => "1.0"}
             } = res

      assert length(data) == 2

      d1data = Enum.find(data, &(&1["id"] == "#{d1.id}"))
      d2data = Enum.find(data, &(&1["id"] == "#{d2.id}"))

      assert d1data["attributes"]["created?"]
      assert d1data["attributes"]["diffs"] == []

      refute d2data["attributes"]["created"]
      assert [[diff]] = d2data["attributes"]["diffs"]
      assert diff =~ "exception dates were added"
    end
  end
end
