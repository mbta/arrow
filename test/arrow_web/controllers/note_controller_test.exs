defmodule ArrowWeb.NoteControllerTest do
  use ArrowWeb.ConnCase, async: true

  import Arrow.Factory

  alias Arrow.Disruption

  describe "create/2" do
    @tag :authenticated_admin
    test "inserts a note when valid", %{conn: conn} do
      %{disruption_id: id} = insert(:disruption_revision, start_date: ~D[2021-01-01])
      params = %{"note" => %{"body" => "This is a note."}}

      conn = post(conn, Routes.note_path(conn, :create, id), params)

      assert redirected_to(conn) == Routes.disruption_path(conn, :show, id)
      disruption = Disruption.get!(id)
      assert [%{body: "This is a note."}] = disruption.notes
    end

    @tag :authenticated_admin
    test "redirects with error when invalid", %{conn: conn} do
      %{disruption_id: id} = insert(:disruption_revision, start_date: ~D[2021-01-01])
      params = %{"note" => %{}}

      conn = post(conn, Routes.note_path(conn, :create, id), params)

      assert redirected_to(conn) == Routes.disruption_path(conn, :show, id)
      assert {_, _} = Phoenix.Flash.get(conn.assigns.flash, :errors)
      disruption = Disruption.get!(id)
      assert disruption.notes == []
    end

    @tag :authenticated
    test "non-admin cannot add note", %{conn: conn} do
      %{disruption_id: id} = insert(:disruption_revision, start_date: ~D[2021-01-01])
      params = %{"note" => %{"body" => "This is a note."}}

      conn = post(conn, Routes.note_path(conn, :create, id), params)

      assert redirected_to(conn) == "/unauthorized"
      disruption = Disruption.get!(id)
      assert disruption.notes == []
    end
  end
end
