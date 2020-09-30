defmodule ArrowWeb.API.PublishNoticeControllerTest do
  use ArrowWeb.ConnCase
  import Arrow.Factory
  import ExUnit.CaptureLog

  describe "publish/2" do
    @tag :authenticated
    test "successfully marks disruption revision as published", %{conn: conn} do
      old_level = Application.get_env(:logger, :level)

      Logger.configure(level: :info)

      on_exit(fn -> Logger.configure(level: old_level) end)

      d = insert(:disruption)
      dr = insert(:disruption_revision, %{disruption: d})
      :ok = Arrow.DisruptionRevision.ready_all!()

      log =
        capture_log([level: :info], fn ->
          conn =
            post(
              conn,
              ArrowWeb.Router.Helpers.notice_path(conn, :publish,
                revision_ids: Integer.to_string(dr.id)
              )
            )

          assert resp = response(conn, 200)

          assert resp == ""

          new_d = Arrow.Repo.get(Arrow.Disruption, d.id)

          assert new_d.published_revision_id == dr.id
        end)

      assert log =~ "marking_revisions_published revision_ids=#{dr.id}"
    end

    @tag :authenticated
    test "returns 400 error when trying to publish a revision more recent than the ready one", %{
      conn: conn
    } do
      d = insert(:disruption)
      dr = insert(:disruption_revision, %{disruption: d})

      conn =
        post(
          conn,
          ArrowWeb.Router.Helpers.notice_path(conn, :publish,
            revision_ids: Integer.to_string(dr.id)
          )
        )

      assert resp = response(conn, 400)

      assert resp == "can't publish revision more recent than ready revision"

      new_d = Arrow.Repo.get(Arrow.Disruption, d.id)

      assert is_nil(new_d.published_revision_id)
    end

    @tag :authenticated
    test "returns 400 error when non-integer argument is given", %{conn: conn} do
      conn =
        post(
          conn,
          ArrowWeb.Router.Helpers.notice_path(conn, :publish, revision_ids: "foo")
        )

      assert resp = response(conn, 400)

      assert resp == "bad argument"
    end
  end

  describe "ready/2" do
    @tag :authenticated
    test "successfully marks disruption revision as ready", %{conn: conn} do
      old_level = Application.get_env(:logger, :level)

      Logger.configure(level: :info)

      on_exit(fn -> Logger.configure(level: old_level) end)

      d = insert(:disruption)
      dr = insert(:disruption_revision, %{disruption: d})

      log =
        capture_log([level: :info], fn ->
          conn =
            post(
              conn,
              ArrowWeb.Router.Helpers.notice_path(conn, :ready,
                revision_ids: Integer.to_string(dr.id)
              )
            )

          assert resp = response(conn, 204)

          assert resp == ""

          new_d = Arrow.Repo.get(Arrow.Disruption, d.id)

          assert new_d.ready_revision_id == dr.id
        end)

      assert log =~ "marking_revisions_ready revision_ids=#{dr.id}"
    end

    @tag :authenticated
    test "returns 400 error when trying to ready a revision that is not the latest one", %{
      conn: conn
    } do
      d = insert(:disruption)
      dr_1 = insert(:disruption_revision, %{disruption: d})
      _dr_2 = insert(:disruption_revision, %{disruption: d})

      conn =
        post(
          conn,
          ArrowWeb.Router.Helpers.notice_path(conn, :ready,
            revision_ids: Integer.to_string(dr_1.id)
          )
        )

      assert resp = response(conn, 400)

      assert resp == "can't ready revision more recent than latest revision"

      new_d = Arrow.Repo.get(Arrow.Disruption, d.id)

      assert is_nil(new_d.ready_revision_id)
    end

    @tag :authenticated
    test "returns 400 error when non-integer argument is given", %{conn: conn} do
      conn =
        post(
          conn,
          ArrowWeb.Router.Helpers.notice_path(conn, :ready, revision_ids: "foo")
        )

      assert resp = response(conn, 400)

      assert resp == "bad argument"
    end
  end
end
