defmodule ArrowWeb.API.PublishNoticeControllerTest do
  use ArrowWeb.ConnCase

  import Arrow.Factory
  import ExUnit.CaptureLog

  describe "publish/2" do
    @tag :authenticated_admin
    test "successfully marks disruption revision as published", %{conn: conn} do
      old_level = Application.get_env(:logger, :level)

      Logger.configure(level: :info)

      on_exit(fn -> Logger.configure(level: old_level) end)

      d = insert(:disruption)
      dr = insert(:disruption_revision, %{disruption: d})

      log =
        capture_log([level: :info], fn ->
          conn =
            post(conn, Routes.notice_path(conn, :publish, revision_ids: Integer.to_string(dr.id)))

          assert resp = response(conn, 200)
          assert resp == ""
          new_d = Arrow.Repo.get(Arrow.Disruption, d.id)
          assert new_d.published_revision_id == dr.id
        end)

      assert log =~ "marking_revisions_published revision_ids=#{dr.id}"
    end

    @tag :authenticated_admin
    test "returns 400 error when non-integer argument is given", %{conn: conn} do
      conn = post(conn, Routes.notice_path(conn, :publish, revision_ids: "foo"))

      assert resp = response(conn, 400)
      assert resp == "bad argument"
    end

    @tag :authenticated
    test "non-admins cannot mark revisions as published", %{conn: conn} do
      old_level = Application.get_env(:logger, :level)

      Logger.configure(level: :info)

      on_exit(fn -> Logger.configure(level: old_level) end)

      d = insert(:disruption)
      dr = insert(:disruption_revision, %{disruption: d})

      log =
        capture_log([level: :info], fn ->
          conn =
            post(conn, Routes.notice_path(conn, :publish, revision_ids: Integer.to_string(dr.id)))

          assert redirected_to(conn) == "/unauthorized"
        end)

      refute log =~ "marking_revisions_published revision_ids=#{dr.id}"
    end
  end
end
