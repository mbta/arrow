defmodule ArrowWeb.TempReviewChangesControllerTest do
  use ArrowWeb.ConnCase
  import Arrow.Factory

  @tag :authenticated
  test "GET /temp_review_changes", %{conn: conn} do
    conn = get(conn, Routes.temp_review_changes_path(conn, :index))
    assert html_response(conn, 200) =~ "Publish all"
  end

  @tag :authenticated
  test "POST /temp_review_changes", %{conn: conn} do
    dr = insert(:disruption_revision)

    conn = post(conn, Routes.temp_review_changes_path(conn, :index))

    assert html_response(conn, 302) =~ Routes.disruption_path(conn, :index)

    new_dr =
      Arrow.DisruptionRevision |> Arrow.Repo.get(dr.id) |> Arrow.Repo.preload([:disruption])

    assert new_dr.disruption.ready_revision_id == dr.id
  end
end
