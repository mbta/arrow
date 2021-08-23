defmodule ArrowWeb.DisruptionControllerTest do
  use ArrowWeb.ConnCase, async: true

  alias Arrow.{Disruption, DisruptionRevision, Repo}
  import Arrow.Factory

  describe "index/2" do
    @tag :authenticated
    test "lists disruptions", %{conn: conn} do
      [%{disruption_id: id1}, %{disruption_id: id2}] =
        Enum.map(0..1, fn _ -> insert_revision_with_everything() end)

      resp = conn |> get(Routes.disruption_path(conn, :index)) |> html_response(200)

      assert resp =~ "#{id1}"
      assert resp =~ "#{id2}"
    end
  end

  describe "show/2" do
    @tag :authenticated
    test "shows a disruption", %{conn: conn} do
      %{disruption_id: id} = insert_revision_with_everything()

      resp = conn |> get(Routes.disruption_path(conn, :show, id)) |> html_response(200)

      assert resp =~ "#{id}"
    end
  end

  describe "delete/2" do
    @tag :authenticated
    test "soft-deletes a disruption", %{conn: conn} do
      %{disruption_id: id} = insert(:disruption_revision, is_active: true)

      redirect = conn |> delete(Routes.disruption_path(conn, :delete, id)) |> redirected_to()

      assert redirect =~ Routes.disruption_path(conn, :show, id)
      refute Repo.get!(DisruptionRevision, Disruption.latest_revision_id(id)).is_active
    end
  end

  defp insert_revision_with_everything do
    insert(:disruption_revision,
      adjustments: [build(:adjustment)],
      days_of_week: [build(:day_of_week)],
      exceptions: [build(:exception)],
      trip_short_names: [build(:trip_short_name)]
    )
  end
end
