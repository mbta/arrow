defmodule ArrowWeb.ShuttleLiveTest do
  use ArrowWeb.ConnCase

  import Phoenix.LiveViewTest
  import Arrow.Factory
  import Arrow.ShuttlesFixtures
  import Mox

  setup :verify_on_exit!

  @create_attrs %{
    disrupted_route_id: "",
    routes: %{
      "0" => %{
        :_persistent_id => "0",
        destination: "Broadway",
        direction_desc: "Southbound",
        direction_id: "0",
        shape_id: "",
        suffix: "",
        waypoint: ""
      },
      "1" => %{
        :_persistent_id => "1",
        destination: "Harvard",
        direction_desc: "Northbound",
        direction_id: "1",
        shape_id: "",
        suffix: "",
        waypoint: ""
      }
    },
    shuttle_name: "Blah",
    status: "draft"
  }

  @update_attrs %{
    disrupted_route_id: "",
    routes: %{
      "0" => %{
        :_persistent_id => "0",
        destination: "Broadway",
        direction_desc: "Southbound",
        direction_id: "0",
        suffix: "",
        waypoint: ""
      },
      "1" => %{
        :_persistent_id => "1",
        destination: "Harvard",
        direction_desc: "Northbound",
        direction_id: "1",
        suffix: "",
        waypoint: ""
      }
    },
    shuttle_name: "Meh",
    status: "draft"
  }

  @update_hidden_attrs %{
    routes: %{
      "0" => %{
        shape_id: "",
        shape_id_text_input: ""
      },
      "1" => %{
        shape_id: "",
        shape_id_text_input: ""
      }
    }
  }

  @invalid_attrs %{
    disrupted_route_id: "",
    shuttle_name: nil,
    status: "draft"
  }

  describe "new shuttle" do
    @tag :authenticated_admin
    test "renders form", %{conn: conn} do
      {:ok, _new_live, html} = live(conn, ~p"/shuttles/new")
      assert html =~ "create new replacement service shuttle"
    end
  end

  describe "create shuttle" do
    @tag :authenticated_admin
    test "redirects to new shuttle when data is valid", %{conn: conn} do
      {:ok, new_live, _html} = live(conn, ~p"/shuttles/new")

      {:ok, conn} =
        new_live
        |> form("#shuttle-form", shuttle: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn)

      assert html_response(conn, 200) =~ ~r/shuttle created successfully/i

      assert %{"id" => _id} = conn.params
    end

    @tag :authenticated_admin
    test "renders errors when data is invalid", %{conn: conn} do
      {:ok, new_live, _html} = live(conn, ~p"/shuttles/new")

      assert new_live |> form("#shuttle-form", shuttle: @invalid_attrs) |> render_submit() =~
               "can&#39;t be blank"
    end
  end

  describe "edit shuttle" do
    setup [:create_shuttle]

    @tag :authenticated_admin
    test "redirects to updated shuttle when data is valid", %{conn: conn, shuttle: shuttle} do
      {:ok, edit_live, _html} = live(conn, ~p"/shuttles/#{shuttle}/edit")

      {:ok, conn} =
        edit_live
        |> form("#shuttle-form", shuttle: @update_attrs)
        |> render_submit(@update_hidden_attrs)
        |> follow_redirect(conn)

      assert html_response(conn, 200) =~ ~r/shuttle updated successfully/i
    end

    @tag :authenticated_admin
    test "can edit a stop ID", %{conn: conn, shuttle: shuttle} do
      direction_0_route = Enum.find(shuttle.routes, fn route -> route.direction_id == :"0" end)
      gtfs_stop = insert(:gtfs_stop)
      new_gtfs_stop = insert(:gtfs_stop)

      direction_0_route
      |> Arrow.Shuttles.Route.changeset(%{
        "route_stops" => [
          %{
            "direction_id" => "0",
            "stop_sequence" => "1",
            "display_stop_id" => gtfs_stop.id
          }
        ]
      })
      |> Arrow.Repo.update()

      shuttle = Arrow.Shuttles.get_shuttle!(shuttle.id)

      {:ok, edit_live, _html} = live(conn, ~p"/shuttles/#{shuttle}/edit")

      {:ok, conn} =
        edit_live
        |> form("#shuttle-form",
          shuttle: @update_attrs,
          routes_with_stops: %{
            "0" => %{route_stops: %{"0" => %{display_stop_id: new_gtfs_stop.id}}}
          }
        )
        |> render_submit()
        |> follow_redirect(conn)

      assert html_response(conn, 200) =~ ~r/shuttle updated successfully/i
    end

    @tag :authenticated_admin
    test "can remove a stop", %{conn: conn, shuttle: shuttle} do
      direction_0_route = Enum.find(shuttle.routes, fn route -> route.direction_id == :"0" end)
      gtfs_stop = insert(:gtfs_stop)

      direction_0_route
      |> Arrow.Shuttles.Route.changeset(%{
        "route_stops" => [
          %{
            "direction_id" => "0",
            "stop_sequence" => "1",
            "display_stop_id" => gtfs_stop.id
          }
        ]
      })
      |> Arrow.Repo.update()

      shuttle = Arrow.Shuttles.get_shuttle!(shuttle.id)

      {:ok, edit_live, _html} = live(conn, ~p"/shuttles/#{shuttle}/edit")

      edit_live
      |> element("#shuttle-form")
      |> render_change(%{
        routes_with_stops: %{"0" => %{"route_stops_drop" => ["0"]}}
      })

      {:ok, conn} =
        edit_live
        |> element("#shuttle-form")
        |> render_submit()
        |> follow_redirect(conn)

      assert html_response(conn, 200) =~ ~r/shuttle updated successfully/i

      updated_shuttle = Arrow.Shuttles.get_shuttle!(shuttle.id)

      assert Enum.all?(updated_shuttle.routes, fn route -> route.route_stops == [] end)
    end

    @tag :authenticated_admin
    test "can add a stop", %{conn: conn, shuttle: shuttle} do
      gtfs_stop = insert(:gtfs_stop)
      stop_id = gtfs_stop.id

      {:ok, edit_live, _html} = live(conn, ~p"/shuttles/#{shuttle}/edit")

      edit_live
      |> element("#shuttle-form #add_stop-0[value=\"0\"]", "Add")
      |> render_click()

      {:ok, conn} =
        edit_live
        |> form("#shuttle-form",
          shuttle: @update_attrs,
          routes_with_stops: %{
            "0" => %{route_stops: %{"0" => %{display_stop_id: stop_id}}}
          }
        )
        |> render_submit()
        |> follow_redirect(conn)

      assert html_response(conn, 200) =~ ~r/shuttle updated successfully/i

      updated_shuttle = Arrow.Shuttles.get_shuttle!(shuttle.id)

      direction_0_route =
        Enum.find(updated_shuttle.routes, fn route -> route.direction_id == :"0" end)

      assert [%{gtfs_stop_id: ^stop_id}] = direction_0_route.route_stops
    end

    @tag :authenticated_admin
    test "can reorder stops", %{conn: conn, shuttle: shuttle} do
      direction_0_route = Enum.find(shuttle.routes, fn route -> route.direction_id == :"0" end)
      [gtfs_stop1, gtfs_stop2, gtfs_stop3] = insert_list(3, :gtfs_stop)

      direction_0_route
      |> Arrow.Shuttles.Route.changeset(%{
        "route_stops" => [
          %{
            "direction_id" => "0",
            "stop_sequence" => "1",
            "display_stop_id" => gtfs_stop1.id
          },
          %{
            "direction_id" => "0",
            "stop_sequence" => "2",
            "display_stop_id" => gtfs_stop2.id
          },
          %{
            "direction_id" => "0",
            "stop_sequence" => "3",
            "display_stop_id" => gtfs_stop3.id
          }
        ]
      })
      |> Arrow.Repo.update()

      shuttle = Arrow.Shuttles.get_shuttle!(shuttle.id)

      {:ok, edit_live, _html} = live(conn, ~p"/shuttles/#{shuttle}/edit")

      edit_live
      |> element("#shuttle-form > div[data-direction_id=\"0\"]")
      |> render_hook(:reorder_stops, %{"direction_id" => "0", "old" => 1, "new" => 0})

      {:ok, conn} =
        edit_live
        |> element("#shuttle-form")
        |> render_submit()
        |> follow_redirect(conn)

      assert html_response(conn, 200) =~ ~r/shuttle updated successfully/i

      updated_shuttle = Arrow.Shuttles.get_shuttle!(shuttle.id)

      direction_0_route =
        Enum.find(updated_shuttle.routes, fn route -> route.direction_id == :"0" end)

      [%{id: stop_id1}, %{id: stop_id2}, %{id: stop_id3}] = [gtfs_stop1, gtfs_stop2, gtfs_stop3]

      assert [%{gtfs_stop_id: ^stop_id2}, %{gtfs_stop_id: ^stop_id1}, %{gtfs_stop_id: ^stop_id3}] =
               direction_0_route.route_stops
    end

    @tag :authenticated_admin
    test "renders errors when data is invalid", %{conn: conn, shuttle: shuttle} do
      {:ok, new_live, _html} = live(conn, ~p"/shuttles/#{shuttle}/edit")

      assert new_live |> form("#shuttle-form", shuttle: @invalid_attrs) |> render_submit() =~
               "can&#39;t be blank"
    end
  end

  describe "retrieve estimates" do
    setup [:create_shuttle_with_stops]
    @tag :authenticated_admin
    test "can retrieve stop duration estimates for stops", %{conn: conn, shuttle: shuttle} do
      expect(Arrow.OpenRouteServiceAPI.MockClient, :get_directions, fn
        %Arrow.OpenRouteServiceAPI.DirectionsRequest{
          coordinates:
            [
              [-71.0589, 42.3601],
              [-71.0589, 42.3601],
              [-71.0589, 42.3601],
              [-71.0589, 42.3601]
            ] = coordinates
        } ->
          {:ok,
           build(:ors_directions_json, %{
             coordinates: coordinates,
             segments: [
               %{
                 "duration" => 100,
                 "distance" => 0.20
               },
               %{
                 "duration" => 300,
                 "distance" => 0.20
               },
               %{
                 "duration" => 100,
                 "distance" => 0.20
               },
               %{
                 "duration" => 100,
                 "distance" => 0.20
               }
             ]
           })}
      end)

      {:ok, edit_live, _html} = live(conn, ~p"/shuttles/#{shuttle}/edit")

      refute edit_live
             |> element(~s{#shuttle-form_routes_0_route_stops_1_time_to_next_stop"})
             |> render() =~ "value"

      edit_live
      |> element("#shuttle-form #get_time-0[value=\"0\"]", "Retrieve Estimates")
      |> render_click()

      assert edit_live
             |> element(~s{#shuttle-form_routes_0_route_stops_1_time_to_next_stop"})
             |> render() =~ "value=\"300\""
    end
  end

  describe "shape select" do
    setup [:create_shuttle]

    @tag :authenticated_admin
    test "sets the selected shape via hidden input values", %{conn: conn, shuttle: shuttle} do
      {:ok, edit_live, _html} = live(conn, ~p"/shuttles/#{shuttle}/edit")

      first_route = List.first(shuttle.routes)
      second_route = Enum.at(shuttle.routes, 1)

      update_first_shape_attrs = %{
        routes: %{
          "0" => %{
            shape_id: second_route.shape_id,
            shape_id_text_input: second_route.shape.name
          }
        }
      }

      # `#` and escaping the brackets doesn't seem to work with this selector format (unlike $() in the browser)
      live_component_selector = ~s{[id="shuttle[routes][0]_shape_id_live_select_component"]}
      hidden_input_selector = ~s{#shuttle-form_routes_0_shape_id}
      displayed_value_selector = ~s{#shuttle-form_routes_0_shape_id_text_input}

      # initially set to original shape
      assert edit_live
             |> element(live_component_selector)
             |> render() =~ ~s{value="#{first_route.shape_id}"}

      assert edit_live
             |> element(displayed_value_selector)
             |> render() =~ ~s{value="#{first_route.shape.name}"}

      assert edit_live
             |> element(hidden_input_selector)
             |> render() =~ ~s{value="#{first_route.shape_id}"}

      rendered =
        edit_live
        |> element("#shuttle-form")
        |> render_change(%{shuttle: update_first_shape_attrs})

      refute rendered =~ "#{first_route.shape.name}"
      assert rendered =~ "#{second_route.shape.name}"

      assert rendered =~
               "name=\"shuttle[routes][0][shape_id]\" type=\"hidden\" value=\"#{second_route.shape_id}\"/>"
    end
  end

  defp create_shuttle_with_stops(_) do
    shuttle = shuttle_fixture(%{}, true)
    %{shuttle: shuttle}
  end

  defp create_shuttle(_) do
    shuttle = shuttle_fixture()
    %{shuttle: shuttle}
  end
end
