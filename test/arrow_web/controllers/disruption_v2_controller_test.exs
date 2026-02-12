defmodule ArrowWeb.DisruptionV2ControllerTest do
  use ArrowWeb.ConnCase

  import Arrow.Factory

  describe "index/2" do
    @tag :authenticated
    test "lists disruptions", %{conn: conn} do
      insert(:limit,
        disruption: build(:disruption_v2, title: "Test disruption"),
        route: build(:gtfs_route, id: "Red")
      )

      resp = conn |> get(~p"/") |> html_response(200)

      assert resp =~ "Test disruption"
    end

    @tag :authenticated
    test "lists disruptions that match a route filter", %{conn: conn} do
      insert(:limit,
        disruption: build(:disruption_v2, title: "Test disruption"),
        route: build(:gtfs_route, id: "Red")
      )

      resp = conn |> get(~p"/?kinds[]=red_line") |> html_response(200)

      assert resp =~ "Test disruption"
    end

    @tag :authenticated
    test "doesn't list disruptions that don't match a route filter", %{conn: conn} do
      insert(:limit,
        disruption: build(:disruption_v2, title: "Test disruption"),
        route: build(:gtfs_route, id: "Red")
      )

      resp = conn |> get(~p"/?kinds[]=orange_line") |> html_response(200)

      refute resp =~ "Test disruption"
    end

    @tag :authenticated
    test "lists only disruptions that satisfy the only_approved filter", %{conn: conn} do
      route = insert(:gtfs_route)

      insert(:limit,
        disruption: build(:disruption_v2, title: "Pending disruption", status: :pending),
        route: route
      )

      insert(:limit,
        disruption: build(:disruption_v2, title: "Approved disruption", status: :approved),
        route: route
      )

      insert(:limit,
        disruption: build(:disruption_v2, title: "Archived disruption", status: :archived),
        route: route
      )

      resp = conn |> get(~p"/?only_approved=true") |> html_response(200)

      refute resp =~ "Pending disruption"
      assert resp =~ "Approved disruption"
      refute resp =~ "Archived disruption"
    end

    @tag :authenticated
    test "lists only disruptions that satisfy the only_archived filter", %{conn: conn} do
      route = insert(:gtfs_route)

      insert(:limit,
        disruption: build(:disruption_v2, title: "Pending disruption", status: :pending),
        route: route
      )

      insert(:limit,
        disruption: build(:disruption_v2, title: "Approved disruption", status: :approved),
        route: route
      )

      insert(:limit,
        disruption: build(:disruption_v2, title: "Archived disruption", status: :archived),
        route: route
      )

      resp = conn |> get(~p"/?only_archived=true") |> html_response(200)

      refute resp =~ "Pending disruption"
      refute resp =~ "Approved disruption"
      assert resp =~ "Archived disruption"
    end

    @tag :authenticated
    test "When there's no filter, lists approved and pending but not archived disruptions", %{
      conn: conn
    } do
      route = insert(:gtfs_route)

      insert(:limit,
        disruption: build(:disruption_v2, title: "Pending disruption", status: :pending),
        route: route
      )

      insert(:limit,
        disruption: build(:disruption_v2, title: "Approved disruption", status: :approved),
        route: route
      )

      insert(:limit,
        disruption: build(:disruption_v2, title: "Archived disruption", status: :archived),
        route: route
      )

      resp = conn |> get(~p"/") |> html_response(200)

      assert resp =~ "Pending disruption"
      assert resp =~ "Approved disruption"
      refute resp =~ "Archived disruption"
    end

    @tag :authenticated
    test "lists disruptions that match a search query on title", %{conn: conn} do
      insert(:disruption_v2, title: "Test disruption Alpha")
      insert(:disruption_v2, title: "Test disruption Beta")

      resp = conn |> get(~p"/?search=Alpha") |> html_response(200)

      assert resp =~ "Test disruption Alpha"
      refute resp =~ "Test disruption Beta"
    end

    @tag :authenticated
    test "lists disruptions that match a search query on stop names", %{conn: conn} do
      route = insert(:gtfs_route)
      start_stop = insert(:gtfs_stop, name: "UniqueStopName Station")
      end_stop = insert(:gtfs_stop, name: "Regular Station")

      insert(:limit,
        disruption: build(:disruption_v2, title: "Matching Disruption"),
        route: route,
        start_stop: start_stop,
        end_stop: end_stop
      )

      insert(:limit,
        disruption: build(:disruption_v2, title: "Nonmatching Disruption"),
        route: route
      )

      resp = conn |> get(~p"/?search=UniqueStopName") |> html_response(200)

      assert resp =~ "Matching Disruption"
      refute resp =~ "Nonmatching Disruption"
    end

    @tag :authenticated
    test "lists disruptions that match a search query on shuttle names", %{conn: conn} do
      route = insert(:gtfs_route)

      disruption_with_shuttle = insert(:disruption_v2, title: "Matching Disruption")
      disruption_without_shuttle = insert(:disruption_v2, title: "Nonmatching Disruption")

      matching_shuttle =
        Arrow.ShuttlesFixtures.shuttle_fixture(
          %{
            shuttle_name: "Right Bus",
            status: :active
          },
          true,
          true
        )

      Arrow.DisruptionsFixtures.replacement_service_fixture(%{
        disruption_id: disruption_with_shuttle.id,
        shuttle_id: matching_shuttle.id,
        start_date: Date.utc_today(),
        end_date: Date.add(Date.utc_today(), 30)
      })

      wrong_shuttle =
        Arrow.ShuttlesFixtures.shuttle_fixture(
          %{
            shuttle_name: "Wrong Bus",
            status: :active
          },
          true,
          true
        )

      Arrow.DisruptionsFixtures.replacement_service_fixture(%{
        disruption_id: disruption_without_shuttle.id,
        shuttle_id: wrong_shuttle.id,
        start_date: Date.utc_today(),
        end_date: Date.add(Date.utc_today(), 30)
      })

      insert(:limit, disruption: disruption_with_shuttle, route: route)
      insert(:limit, disruption: disruption_without_shuttle, route: route)

      resp = conn |> get(~p"/?search=Right") |> html_response(200)

      assert resp =~ "Matching Disruption"
      refute resp =~ "Nonmatching Disruption"
    end

    @tag :authenticated
    test "search is case-insensitive", %{conn: conn} do
      insert(:disruption_v2, title: "Case Sensitive Test")

      resp = conn |> get(~p"/?search=case sensitive") |> html_response(200)

      assert resp =~ "Case Sensitive Test"
    end

    @tag :authenticated
    test "empty search string returns all disruptions", %{conn: conn} do
      insert(:disruption_v2, title: "Test disruption Alpha")
      insert(:disruption_v2, title: "Test disruption Beta")

      resp = conn |> get(~p"/?search=") |> html_response(200)

      assert resp =~ "Alpha"
      assert resp =~ "Beta"
    end
  end
end
