defmodule ArrowWeb.FeedControllerTest do
  use ArrowWeb.ConnCase

  import Arrow.Factory

  describe "GET /feed" do
    @tag :authenticated_admin
    test "does not show up-to-date disruptions", %{conn: conn} do
      d = insert(:disruption)
      dr = insert(:disruption_revision, %{disruption: d})
      Arrow.Repo.update!(Ecto.Changeset.change(d, %{published_revision_id: dr.id}))

      conn = get(conn, "/feed")

      refute html_response(conn, 200) =~ "Disruption ##{d.id}"
    end

    @tag :authenticated_admin
    test "shows disruptions with changes since published version", %{conn: conn} do
      d = insert(:disruption)
      dr = insert(:disruption_revision, %{disruption: d})
      Arrow.Repo.update!(Ecto.Changeset.change(d, %{published_revision_id: dr.id}))
      dr2 = insert(:disruption_revision, %{disruption: d})
      dr3 = insert(:disruption_revision, %{disruption: d})

      conn = get(conn, "/feed")

      assert html = html_response(conn, 200)
      assert html =~ "Disruption ##{d.id}"
      assert html =~ "disruption was updated"
      assert html =~ "Revision ##{dr.id}"
      assert html =~ "Revision ##{dr3.id}"
      refute html =~ "Revision ##{dr2.id}"
    end

    @tag :authenticated_admin
    test "shows new disruptions", %{conn: conn} do
      d = insert(:disruption)
      insert(:disruption_revision, %{disruption: d})

      conn = get(conn, "/feed")

      assert html = html_response(conn, 200)
      assert html =~ "A new, unpublished disruption"
      assert html =~ "Disruption ##{d.id}"
    end

    @tag :authenticated
    test "non-admin can't view the feed", %{conn: conn} do
      assert conn |> get("/feed") |> redirected_to() == "/unauthorized"
    end
  end
end
