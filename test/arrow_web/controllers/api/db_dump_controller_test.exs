defmodule ArrowWeb.API.DBDumpControllerTest do
  use ArrowWeb.ConnCase

  describe "show/2" do
    @tag :authenticated
    test "returns JSON with database contents", %{conn: conn} do
      conn = get(conn, ArrowWeb.Router.Helpers.db_dump_path(conn, :show))

      assert resp = json_response(conn, 200)

      keys = Map.keys(resp)

      assert "adjustments" in keys
      assert "disruption_adjustments" in keys
      assert "disruption_day_of_weeks" in keys
      assert "disruption_exceptions" in keys
      assert "disruption_revisions" in keys
      assert "disruption_trip_short_names" in keys
      assert "disruptions" in keys
    end
  end
end
