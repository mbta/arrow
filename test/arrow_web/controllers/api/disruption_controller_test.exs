defmodule ArrowWeb.API.DisruptionControllerTest do
  use ArrowWeb.ConnCase
  import Arrow.Factory
  alias Arrow.{Disruption, Repo}
  alias Ecto.Changeset

  describe "index/2" do
    @tag :authenticated
    test "non-admin user can't access the disruptions API", %{conn: conn} do
      assert conn |> get("/api/disruptions") |> redirected_to() == "/unauthorized"
    end

    @tag :authenticated_admin
    test "returns 200", %{conn: conn} do
      assert %{status: 200} = get(conn, "/api/disruptions")
    end

    @tag :authenticated_admin
    test "includes all revisions for all disruptions", %{conn: conn} do
      d1 = insert(:disruption)

      _dr1 =
        insert(:disruption_revision,
          disruption: d1,
          start_date: ~D[2019-10-10],
          end_date: ~D[2019-11-01]
        )

      d2 = insert(:disruption)

      dr2 =
        insert(:disruption_revision,
          disruption: d2,
          start_date: ~D[2019-10-10],
          end_date: ~D[2019-11-01]
        )

      {:ok, _revision} = Disruption.update(d1.id, %{end_date: ~D[2019-12-01]})

      new_d1 =
        Disruption
        |> Repo.get(d1.id)
        |> Repo.preload([:revisions])

      new_d1
      |> Changeset.change(%{published_revision_id: Enum.at(new_d1.revisions, -1).id})
      |> Repo.update!()

      {:ok, _revision} = Disruption.update(d1.id, %{end_date: ~D[2020-01-01]})

      res = json_response(get(conn, "/api/disruptions"), 200)

      assert %{
               "data" => data,
               "included" => included,
               "jsonapi" => %{"version" => "1.0"}
             } = res

      included_map = Map.new(included, fn inc -> {{inc["type"], inc["id"]}, inc} end)

      d1_data = Enum.find(data, &(&1["id"] == Integer.to_string(d1.id)))
      d2_data = Enum.find(data, &(&1["id"] == Integer.to_string(d2.id)))

      d1_published_id = Integer.to_string(Enum.at(new_d1.revisions, -1).id)
      d2_latest_id = Integer.to_string(dr2.id)

      assert %{
               "id" => _,
               "relationships" => %{
                 "published_revision" => %{
                   "data" => %{
                     "id" => ^d1_published_id,
                     "type" => "disruption_revision"
                   }
                 },
                 "revisions" => %{"data" => d1_revisions}
               },
               "type" => "disruption"
             } = d1_data

      d1_revision_ids =
        d1_revisions
        |> Enum.map(&String.to_integer(&1["id"]))
        |> Enum.sort()
        |> Enum.map(&Integer.to_string(&1))

      d1_revision1 = included_map[{"disruption_revision", Enum.at(d1_revision_ids, 0)}]
      d1_revision2 = included_map[{"disruption_revision", Enum.at(d1_revision_ids, 1)}]

      assert %{
               "attributes" => %{
                 "start_date" => "2019-10-10",
                 "end_date" => "2019-12-01",
                 "is_active" => true
               }
             } = d1_revision1

      assert %{
               "attributes" => %{
                 "start_date" => "2019-10-10",
                 "end_date" => "2020-01-01",
                 "is_active" => true
               }
             } = d1_revision2

      assert %{
               "id" => _,
               "relationships" => %{
                 "published_revision" => %{"data" => nil},
                 "revisions" => %{
                   "data" => [%{"id" => ^d2_latest_id, "type" => "disruption_revision"}]
                 }
               },
               "type" => "disruption"
             } = d2_data

      d2_revision1 = included_map[{"disruption_revision", d2_latest_id}]

      assert %{
               "attributes" => %{
                 "start_date" => "2019-10-10",
                 "end_date" => "2019-11-01",
                 "is_active" => true
               }
             } = d2_revision1
    end
  end
end
