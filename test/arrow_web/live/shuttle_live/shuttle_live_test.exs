defmodule ArrowWeb.ShuttleLiveTest do
  use ArrowWeb.ConnCase

  import Phoenix.LiveViewTest
  import Arrow.Factory
  import Arrow.ShuttlesFixtures
  import Mox

  setup :verify_on_exit!

  @create_attrs %{
    disrupted_route_id: "",
    suffix: "",
    routes: %{
      "0" => %{
        :_persistent_id => "0",
        destination: "Broadway",
        direction_desc: "South",
        direction_id: "0",
        shape_id: "",
        waypoint: ""
      },
      "1" => %{
        :_persistent_id => "1",
        destination: "Harvard",
        direction_desc: "North",
        direction_id: "1",
        shape_id: "",
        waypoint: ""
      }
    },
    shuttle_name: "Blah",
    status: "draft"
  }

  @update_attrs %{
    disrupted_route_id: "",
    suffix: "",
    routes: %{
      "0" => %{
        :_persistent_id => "0",
        destination: "Broadway",
        direction_desc: "Outbound",
        direction_id: "0",
        waypoint: ""
      },
      "1" => %{
        :_persistent_id => "1",
        destination: "Harvard",
        direction_desc: "North",
        direction_id: "1",
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
    test "redirects to shuttles table when data is valid", %{conn: conn} do
      {:ok, new_live, _html} = live(conn, ~p"/shuttles/new")

      {:ok, conn} =
        new_live
        |> form("#shuttle-form", shuttle: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn)

      assert html_response(conn, 200) =~ ~r/shuttle created successfully/i
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
      stop_id = new_gtfs_stop.id

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

      edit_stop_attrs = %{
        routes: %{
          "0" => %{
            route_stops: %{
              "0" => %{
                display_stop_id: stop_id,
                display_stop_id_text_input: stop_id
              }
            }
          }
        }
      }

      assert edit_live
             |> form("#shuttle-form")
             |> render_change(shuttle: edit_stop_attrs)
             |> Floki.find("#shuttle_routes_0_route_stops_0_display_stop_id")
             |> Floki.attribute("value")
             |> List.first() =~ "#{stop_id}"

      {:ok, conn} =
        edit_live
        |> form("#shuttle-form")
        |> render_submit()
        |> follow_redirect(conn)

      assert html_response(conn, 200) =~ ~r/shuttle updated successfully/i

      updated_shuttle = Arrow.Shuttles.get_shuttle!(shuttle.id)

      direction_0_route =
        Enum.find(updated_shuttle.routes, fn route -> route.direction_id == :"0" end)

      assert [%{gtfs_stop_id: ^stop_id}] = direction_0_route.route_stops
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
        shuttle: %{
          routes: %{"0" => %{"route_stops_drop" => ["0"]}}
        }
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

      add_stop_attrs = %{
        routes: %{
          "0" => %{
            destination: "Broadway",
            direction_desc: "South",
            direction_id: "0",
            waypoint: "",
            route_stops: %{
              "0" => %{
                display_stop_id: gtfs_stop.id,
                display_stop_id_text_input: stop_id
              }
            }
          }
        }
      }

      assert edit_live
             |> form("#shuttle-form")
             |> render_change(shuttle: add_stop_attrs)
             |> Floki.find("#shuttle_routes_0_route_stops_0_display_stop_id")
             |> Floki.attribute("value")
             |> List.first() =~ "#{stop_id}"

      {:ok, conn} =
        edit_live
        |> form("#shuttle-form")
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
      |> element("#stops-dir-0[data-direction_id=\"0\"]")
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

      assert [
               %{gtfs_stop_id: ^stop_id2, stop_sequence: 1, display_stop_id: ^stop_id2},
               %{gtfs_stop_id: ^stop_id1, stop_sequence: 2, display_stop_id: ^stop_id1},
               %{gtfs_stop_id: ^stop_id3, stop_sequence: 3, display_stop_id: ^stop_id3}
             ] =
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
             |> element(~s{#shuttle_routes_0_route_stops_1_time_to_next_stop"})
             |> render() =~ "value"

      edit_live
      |> element("#shuttle-form #get_time-0[value=\"0\"]", "Retrieve Estimates")
      |> render_click()

      assert edit_live
             |> element(~s{#shuttle_routes_0_route_stops_1_time_to_next_stop"})
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
      hidden_input_selector = ~s{#shuttle_routes_0_shape_id}
      displayed_value_selector = ~s{#shuttle_routes_0_shape_id_text_input}

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

  describe "upload definition" do
    @tag :authenticated_admin
    test "sets route_stops using uploaded stop IDs", %{conn: conn} do
      {:ok, new_live, _html} = live(conn, ~p"/shuttles/new")

      definition =
        file_input(new_live, "#shuttle-form", :definition, [
          %{
            name: "valid.xlsx",
            content: File.read!("test/support/fixtures/xlsx/shuttle_live/valid.xlsx")
          }
        ])

      direction_0_stop_sequence = ~w(9328 5327 5271)
      direction_1_stop_sequence = ~w(5271 5072 9328)

      (direction_0_stop_sequence ++ direction_1_stop_sequence)
      |> Enum.uniq()
      |> Enum.map(fn stop_id ->
        insert(:gtfs_stop, %{id: stop_id})
      end)

      html = render_upload(definition, "valid.xlsx")

      direction_0_stop_rows = Floki.find(html, "#stops-dir-0 > .row")
      direction_1_stop_rows = Floki.find(html, "#stops-dir-1 > .row")

      for {stop_id, index} <- Enum.with_index(direction_0_stop_sequence, 1) do
        [stop] =
          Floki.attribute(
            direction_0_stop_rows,
            "[data-stop_sequence=#{index}] > div > div.form-group > div > div > div > input[type=text]",
            "value"
          )

        assert stop =~ stop_id
      end

      for {stop_id, index} <- Enum.with_index(direction_1_stop_sequence, 1) do
        [stop] =
          Floki.attribute(
            direction_1_stop_rows,
            "[data-stop_sequence=#{index}] > div > div.form-group > div > div > div > input[type=text]",
            "value"
          )

        assert stop =~ stop_id
      end
    end

    @tag :authenticated_admin
    test "displays error if uploaded stop IDs contain invalid stop IDs", %{conn: conn} do
      {:ok, new_live, _html} = live(conn, ~p"/shuttles/new")

      definition =
        file_input(new_live, "#shuttle-form", :definition, [
          %{
            name: "valid.xlsx",
            content: File.read!("test/support/fixtures/xlsx/shuttle_live/valid.xlsx")
          }
        ])

      direction_0_stop_sequence = ~w(9328 5327 5271)
      direction_1_stop_sequence = ~w(5271 5072 9328)

      html = render_upload(definition, "valid.xlsx")

      assert html =~ "Failed to upload definition:"
      assert html =~ "not a valid stop ID &#39;9328"
      assert html =~ "not a valid stop ID &#39;5072"

      direction_0_stop_rows = Floki.find(html, "#stops-dir-0 > .row")
      direction_1_stop_rows = Floki.find(html, "#stops-dir-1 > .row")

      for {_stop_id, index} <- Enum.with_index(direction_0_stop_sequence, 1) do
        assert [] =
                 Floki.attribute(
                   direction_0_stop_rows,
                   "[data-stop_sequence=#{index}] > div > div.form-group > div > div > div > input[type=text]",
                   "value"
                 )
      end

      for {_stop_id, index} <- Enum.with_index(direction_1_stop_sequence, 1) do
        assert [] =
                 Floki.attribute(
                   direction_1_stop_rows,
                   "[data-stop_sequence=#{index}] > div > div.form-group > div > div > div > input[type=text]",
                   "value"
                 )
      end
    end

    @tag :authenticated_admin
    test "displays error for missing/invalid tabs", %{conn: conn} do
      {:ok, new_live, _html} = live(conn, ~p"/shuttles/new")

      definition =
        file_input(new_live, "#shuttle-form", :definition, [
          %{
            name: "invalid_missing_tab.xlsx",
            content:
              File.read!("test/support/fixtures/xlsx/shuttle_live/invalid_missing_tab.xlsx")
          }
        ])

      page = render_upload(definition, "invalid_missing_tab.xlsx")
      assert page =~ "Failed to upload definition:"
      assert page =~ "Missing Direction 0 STOPS tab"
    end

    @tag :authenticated_admin
    test "displays error for missing/invalid data", %{conn: conn} do
      {:ok, new_live, _html} = live(conn, ~p"/shuttles/new")

      definition =
        file_input(new_live, "#shuttle-form", :definition, [
          %{
            name: "invalid_missing_data.xlsx",
            content:
              File.read!("test/support/fixtures/xlsx/shuttle_live/invalid_missing_data.xlsx")
          }
        ])

      page = render_upload(definition, "invalid_missing_data.xlsx")
      assert page =~ "Failed to upload definition:"
      assert page =~ "Tab Direction 0 STOPS, row 3: missing/invalid stop ID"
      assert page =~ "Tab Direction 1 STOPS, row 2: missing/invalid stop ID"
      assert page =~ "Tab Direction 1 STOPS, row 3: missing/invalid stop ID"
    end

    @tag :authenticated_admin

    test "displays error for missing headers", %{conn: conn} do
      {:ok, new_live, _html} = live(conn, ~p"/shuttles/new")

      definition =
        file_input(new_live, "#shuttle-form", :definition, [
          %{
            name: "invalid_missing_headers.xlsx",
            content:
              File.read!("test/support/fixtures/xlsx/shuttle_live/invalid_missing_headers.xlsx")
          }
        ])

      page = render_upload(definition, "invalid_missing_headers.xlsx")
      assert page =~ "Failed to upload definition:"
      assert page =~ "Unable to parse Stop ID column"
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
