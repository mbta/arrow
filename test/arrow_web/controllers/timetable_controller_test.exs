defmodule ArrowWeb.TimetableControllerTest do
  use ArrowWeb.ConnCase

  import Arrow.Factory

  describe "show/2" do
    @tag :authenticated_admin
    test "renders timetable", %{conn: conn} do
      shuttle = Arrow.ShuttlesFixtures.shuttle_fixture(%{}, true, true)

      replacement_service =
        insert(:replacement_service, shuttle: shuttle)

      conn = get(conn, ~p"/replacement_services/#{replacement_service.id}/timetable")

      response = html_response(conn, 200)

      assert response =~ "view timetable: some shuttle_name"
      assert response =~ "Test Stop to Test Stop"
      assert response =~ "05:10"

      # can switch direction
      assert response =~ "/timetable?day_of_week=WKDY&amp;direction_id=1"

      # can switch day
      assert response =~ "/timetable?day_of_week=WKDY&amp;direction_id=0"
      assert response =~ "/timetable?day_of_week=SAT&amp;direction_id=0"
    end

    @tag :authenticated_admin
    test "renders timetable, opposite direction", %{conn: conn} do
      shuttle = Arrow.ShuttlesFixtures.shuttle_fixture(%{}, true, true)

      replacement_service =
        insert(:replacement_service, shuttle: shuttle)

      conn =
        get(conn, ~p"/replacement_services/#{replacement_service.id}/timetable?direction_id=1")

      response = html_response(conn, 200)

      # can switch direction
      assert response =~ "/timetable?day_of_week=WKDY&amp;direction_id=0"

      # can switch day
      assert response =~ "/timetable?day_of_week=WKDY&amp;direction_id=1"
      assert response =~ "/timetable?day_of_week=SAT&amp;direction_id=1"
    end
  end
end
