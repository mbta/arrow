defmodule ArrowWeb.ReplacementServiceTimetableControllerTest do
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
      assert response =~ "/timetable?day_of_week=weekday&amp;direction_id=1"

      # can switch day
      assert response =~ "/timetable?day_of_week=weekday&amp;direction_id=0"
      assert response =~ "/timetable?day_of_week=saturday&amp;direction_id=0"
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
      assert response =~ "/timetable?day_of_week=weekday&amp;direction_id=0"

      # can switch day
      assert response =~ "/timetable?day_of_week=weekday&amp;direction_id=1"
      assert response =~ "/timetable?day_of_week=saturday&amp;direction_id=1"
    end

    @tag :authenticated_admin
    test "renders friday timetable", %{conn: conn} do
      shuttle = Arrow.ShuttlesFixtures.shuttle_fixture(%{}, true, true)

      replacement_service =
        insert(:replacement_service,
          shuttle: shuttle,
          source_workbook_data: %{
            "FRI headways and runtimes" => [
              %{
                "end_time" => "06:00",
                "headway" => 10,
                "running_time_0" => 25,
                "running_time_1" => 15,
                "start_time" => "05:00"
              },
              %{
                "end_time" => "07:00",
                "headway" => 15,
                "running_time_0" => 30,
                "running_time_1" => 20,
                "start_time" => "06:00"
              },
              %{"first_trip_0" => "05:10", "first_trip_1" => "05:10"},
              %{"last_trip_0" => "06:30", "last_trip_1" => "06:30"}
            ],
            "SAT headways and runtimes" => [
              %{
                "end_time" => "06:00",
                "headway" => 10,
                "running_time_0" => 25,
                "running_time_1" => 15,
                "start_time" => "05:00"
              },
              %{
                "end_time" => "07:00",
                "headway" => 15,
                "running_time_0" => 30,
                "running_time_1" => 20,
                "start_time" => "06:00"
              },
              %{"first_trip_0" => "05:10", "first_trip_1" => "05:10"},
              %{"last_trip_0" => "06:30", "last_trip_1" => "06:30"}
            ]
          }
        )

      conn =
        get(
          conn,
          ~p"/replacement_services/#{replacement_service.id}/timetable?day_of_week=friday&direction_id=0"
        )

      response = html_response(conn, 200)

      assert response =~ "view timetable: some shuttle_name"
      assert response =~ "Test Stop to Test Stop"
      assert response =~ "05:10"

      # can switch direction
      assert response =~ "/timetable?day_of_week=friday&amp;direction_id=1"

      # can switch day
      assert response =~ "/timetable?day_of_week=friday&amp;direction_id=0"
      assert response =~ "/timetable?day_of_week=saturday&amp;direction_id=0"
    end
  end
end
