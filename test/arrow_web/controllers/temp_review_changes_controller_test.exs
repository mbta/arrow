defmodule ArrowWeb.TempReviewChangesControllerTest do
  use ArrowWeb.ConnCase
  import Arrow.Factory
  import ArrowWeb.Router.Helpers

  @tag :authenticated
  test "GET /temp_review_changes", %{conn: conn} do
    conn = get(conn, temp_review_changes_path(conn, :index))
    assert html_response(conn, 200) =~ "Publish all"
  end

  @tag :authenticated
  test "POST /temp_review_changes", %{conn: conn} do
    dr = insert(:disruption_revision)

    conn = post(conn, temp_review_changes_path(conn, :index))

    assert html_response(conn, 302) =~ disruption_path(conn, :index)

    new_dr =
      Arrow.DisruptionRevision |> Arrow.Repo.get(dr.id) |> Arrow.Repo.preload([:disruption])

    assert new_dr.disruption.ready_revision_id == dr.id
  end
end
