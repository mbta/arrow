defmodule Arrow.Shuttles.ShuttleTest do
  use Arrow.DataCase

  alias Arrow.Shuttles.Shuttle

  import Arrow.Factory
  import Arrow.ShuttlesFixtures
  import Test.Support.Helpers

  describe "changeset/2" do
    test "cannot mark a shuttle as active without at least two shuttle_stops per shuttle_route" do
      shuttle = shuttle_fixture()

      changeset = Shuttle.changeset(shuttle, %{status: :active})

      assert %Ecto.Changeset{
               valid?: false,
               errors: [status: {"must have at least two stops in each direction", []}]
             } = changeset
    end

    test "cannot mark a shuttle as active without every route having a shape" do
      shuttle = shuttle_fixture()
      [route0, route1] = shuttle.routes

      [stop1, stop2, stop3, stop4] = insert_list(4, :gtfs_stop)

      route0
      |> Arrow.Shuttles.Route.changeset(%{
        "route_stops" => [
          %{
            "direction_id" => "0",
            "stop_sequence" => "1",
            "display_stop_id" => stop1.id,
            "time_to_next_stop" => 30.0
          },
          %{
            "direction_id" => "0",
            "stop_sequence" => "2",
            "display_stop_id" => stop2.id
          }
        ],
        "shape_id" => nil
      })
      |> Arrow.Repo.update()

      route1
      |> Arrow.Shuttles.Route.changeset(%{
        "route_stops" => [
          %{
            "direction_id" => "1",
            "stop_sequence" => "1",
            "display_stop_id" => stop3.id,
            "time_to_next_stop" => 30.0
          },
          %{
            "direction_id" => "0",
            "stop_sequence" => "2",
            "display_stop_id" => stop4.id
          }
        ]
      })
      |> Arrow.Repo.update()

      shuttle = Arrow.Shuttles.get_shuttle!(shuttle.id)

      changeset =
        Shuttle.changeset(shuttle, %{
          status: :active,
          routes: [
            %{
              id: route0.id,
              destination: "Harvard",
              direction_id: :"0",
              direction_desc: "South",
              waypoint: "Brattle",
              route_stops: [
                %{
                  direction_id: :"0",
                  stop_sequence: 1,
                  display_stop_id: stop1.id,
                  time_to_next_stop: 60.0
                },
                %{
                  direction_id: :"0",
                  stop_sequence: 2,
                  display_stop_id: stop2.id
                }
              ]
            },
            %{
              id: route1.id,
              destination: "Alewife",
              direction_id: :"1",
              direction_desc: "North",
              waypoint: "Brattle",
              route_stops: [
                %{
                  direction_id: :"1",
                  stop_sequence: 1,
                  display_stop_id: stop3.id,
                  time_to_next_stop: 60.0
                },
                %{
                  direction_id: :"0",
                  stop_sequence: 1,
                  display_stop_id: stop4.id
                }
              ]
            }
          ]
        })

      assert %Ecto.Changeset{
               valid?: false,
               errors: [status: {"all routes must have an associated shape", []}]
             } = changeset
    end

    test "cannot mark a shuttle as active without times to next stop on applicable stops" do
      shuttle = shuttle_fixture()
      [route0, route1] = shuttle.routes

      [stop1, stop2, stop3, stop4] = insert_list(4, :gtfs_stop)

      route0
      |> Arrow.Shuttles.Route.changeset(%{
        "route_stops" => [
          %{
            "direction_id" => "0",
            "stop_sequence" => "1",
            "display_stop_id" => stop1.id,
            "time_to_next_stop" => 30.0
          },
          %{
            "direction_id" => "0",
            "stop_sequence" => "2",
            "display_stop_id" => stop2.id
          }
        ]
      })
      |> Arrow.Repo.update()

      route1
      |> Arrow.Shuttles.Route.changeset(%{
        "route_stops" => [
          %{
            "direction_id" => "1",
            "stop_sequence" => "1",
            "display_stop_id" => stop3.id
          },
          %{
            "direction_id" => "0",
            "stop_sequence" => "1",
            "display_stop_id" => stop4.id
          }
        ]
      })
      |> Arrow.Repo.update()

      shuttle = Arrow.Shuttles.get_shuttle!(shuttle.id)

      changeset =
        Shuttle.changeset(shuttle, %{status: :active})

      assert %Ecto.Changeset{
               valid?: false,
               errors: [
                 status:
                   {"all stops except the last in each direction must have a time to next stop",
                    []}
               ]
             } = changeset
    end

    test "can mark a shuttle as active with at least two shuttle_stops per shuttle_route and time_to_next_stop values" do
      shuttle = shuttle_fixture()
      [route0, route1] = shuttle.routes

      [stop1, stop2, stop3, stop4] = insert_list(4, :gtfs_stop)

      route0
      |> Arrow.Shuttles.Route.changeset(%{
        "route_stops" => [
          %{
            "direction_id" => "0",
            "stop_sequence" => "1",
            "display_stop_id" => stop1.id,
            "time_to_next_stop" => 30.0
          },
          %{
            "direction_id" => "0",
            "stop_sequence" => "2",
            "display_stop_id" => stop2.id
          }
        ]
      })
      |> Arrow.Repo.update()

      route1
      |> Arrow.Shuttles.Route.changeset(%{
        "route_stops" => [
          %{
            "direction_id" => "1",
            "stop_sequence" => "1",
            "display_stop_id" => stop3.id,
            "time_to_next_stop" => 30.0
          },
          %{
            "direction_id" => "0",
            "stop_sequence" => "2",
            "display_stop_id" => stop4.id
          }
        ]
      })
      |> Arrow.Repo.update()

      shuttle = Arrow.Shuttles.get_shuttle!(shuttle.id)

      # Update the route_stops to trigger replacement and verify that
      # the validation handles that correctly
      changeset =
        Shuttle.changeset(shuttle, %{
          status: :active,
          routes: [
            %{
              id: route0.id,
              shape_id: route0.shape_id,
              destination: "Harvard",
              direction_id: :"0",
              direction_desc: "South",
              waypoint: "Brattle",
              route_stops: [
                %{
                  direction_id: :"0",
                  stop_sequence: 1,
                  display_stop_id: stop1.id,
                  time_to_next_stop: 60.0
                },
                %{
                  direction_id: :"0",
                  stop_sequence: 2,
                  display_stop_id: stop2.id
                }
              ]
            },
            %{
              id: route1.id,
              shape_id: route1.shape_id,
              destination: "Alewife",
              direction_id: :"1",
              direction_desc: "North",
              waypoint: "Brattle",
              route_stops: [
                %{
                  direction_id: :"1",
                  stop_sequence: 1,
                  display_stop_id: stop3.id,
                  time_to_next_stop: 60.0
                },
                %{
                  direction_id: :"0",
                  stop_sequence: 1,
                  display_stop_id: stop4.id
                }
              ]
            }
          ]
        })

      assert %Ecto.Changeset{valid?: true} = changeset
    end

    test "cannot mark a shuttle as inactive when in use by a replacement service" do
      shuttle = shuttle_fixture()
      [route0, route1] = shuttle.routes

      [stop1, stop2, stop3, stop4] = insert_list(4, :gtfs_stop)

      route0
      |> Arrow.Shuttles.Route.changeset(%{
        "route_stops" => [
          %{
            "direction_id" => "0",
            "stop_sequence" => "1",
            "display_stop_id" => stop1.id,
            "time_to_next_stop" => 30.0
          },
          %{
            "direction_id" => "0",
            "stop_sequence" => "2",
            "display_stop_id" => stop2.id
          }
        ]
      })
      |> Arrow.Repo.update()

      route1
      |> Arrow.Shuttles.Route.changeset(%{
        "route_stops" => [
          %{
            "direction_id" => "1",
            "stop_sequence" => "1",
            "display_stop_id" => stop3.id,
            "time_to_next_stop" => 30.0
          },
          %{
            "direction_id" => "0",
            "stop_sequence" => "2",
            "display_stop_id" => stop4.id
          }
        ]
      })
      |> Arrow.Repo.update()

      {:ok, shuttle} =
        shuttle.id
        |> Arrow.Shuttles.get_shuttle!()
        |> Shuttle.changeset(%{status: :active})
        |> Arrow.Repo.update()

      disruption = insert(:disruption_v2)
      insert(:replacement_service, shuttle: shuttle, disruption: disruption)

      changeset = Shuttle.changeset(shuttle, %{status: :draft})

      expected_error_msg =
        ~s|can't deactivate: shuttle is in use by approved disruption(s) that have current or upcoming replacement services: "#{disruption.title}"|

      assert %Ecto.Changeset{
               valid?: false,
               errors: [
                 status: {^expected_error_msg, []}
               ]
             } = changeset
    end

    test "can mark a shuttle as inactive when not in use by a replacement service" do
      shuttle = shuttle_fixture()
      [route0, route1] = shuttle.routes

      [stop1, stop2, stop3, stop4] = insert_list(4, :gtfs_stop)

      route0
      |> Arrow.Shuttles.Route.changeset(%{
        "route_stops" => [
          %{
            "direction_id" => "0",
            "stop_sequence" => "1",
            "display_stop_id" => stop1.id,
            "time_to_next_stop" => 30.0
          },
          %{
            "direction_id" => "0",
            "stop_sequence" => "2",
            "display_stop_id" => stop2.id
          }
        ]
      })
      |> Arrow.Repo.update()

      route1
      |> Arrow.Shuttles.Route.changeset(%{
        "route_stops" => [
          %{
            "direction_id" => "1",
            "stop_sequence" => "1",
            "display_stop_id" => stop3.id,
            "time_to_next_stop" => 30.0
          },
          %{
            "direction_id" => "0",
            "stop_sequence" => "2",
            "display_stop_id" => stop4.id
          }
        ]
      })
      |> Arrow.Repo.update()

      {:ok, shuttle} =
        shuttle.id
        |> Arrow.Shuttles.get_shuttle!()
        |> Shuttle.changeset(%{status: :active})
        |> Arrow.Repo.update()

      changeset = Shuttle.changeset(shuttle, %{status: :draft})

      assert %Ecto.Changeset{valid?: true} = changeset
    end

    test "cannot mark a shuttle as active when stops are too far from shape" do
      reassign_env(:shape_storage_enabled?, true)
      shape = s3_mocked_shape_fixture()

      shuttle = shuttle_fixture()
      [route0, route1] = shuttle.routes

      stop1 = insert(:gtfs_stop, %{lat: 40.0, lon: -71.1})
      stop2 = insert(:gtfs_stop, %{lat: 42.2, lon: -70.0})
      stop3 = insert(:gtfs_stop, %{lat: 43.0, lon: -71.2})
      stop4 = insert(:gtfs_stop, %{lat: 42.2, lon: -72.0})

      route0_attrs = %{
        "shape_id" => shape.id,
        "route_stops" => [
          %{
            "direction_id" => "0",
            "stop_sequence" => "1",
            "display_stop_id" => stop1.id,
            "time_to_next_stop" => 30.0
          },
          %{
            "direction_id" => "0",
            "stop_sequence" => "2",
            "display_stop_id" => stop2.id
          }
        ]
      }

      {:ok, _} =
        route0
        |> Arrow.Shuttles.Route.changeset(route0_attrs)
        |> Arrow.Repo.update()

      route1_attrs = %{
        "shape_id" => shape.id,
        "route_stops" => [
          %{
            "direction_id" => "1",
            "stop_sequence" => "1",
            "display_stop_id" => stop3.id,
            "time_to_next_stop" => 30.0
          },
          %{
            "direction_id" => "1",
            "stop_sequence" => "2",
            "display_stop_id" => stop4.id
          }
        ]
      }

      {:ok, _} =
        route1
        |> Arrow.Shuttles.Route.changeset(route1_attrs)
        |> Arrow.Repo.update()

      shuttle = Arrow.Shuttles.get_shuttle!(shuttle.id)

      changeset =
        Shuttle.changeset(shuttle, %{
          status: :active,
          routes: %{
            "0" => Map.put(route0_attrs, "id", route0.id),
            "1" => Map.put(route1_attrs, "id", route1.id)
          }
        })

      assert %Ecto.Changeset{valid?: false} = changeset

      routes = Ecto.Changeset.get_change(changeset, :routes)
      assert length(routes) == 2

      for route <- routes do
        route_stops = Ecto.Changeset.get_change(route, :route_stops)

        assert Enum.any?(route_stops, fn rs ->
                 errors = rs.errors

                 case errors[:display_stop_id] do
                   {error_msg, _} ->
                     error_msg =~ "from shape (max allowed: 150m)"

                   _ ->
                     false
                 end
               end)
      end
    end

    test "can mark a shuttle as active when all stops are within 150m of shape" do
      reassign_env(:shape_storage_enabled?, true)
      shape = s3_mocked_shape_fixture()

      shuttle = shuttle_fixture()
      [route0, route1] = shuttle.routes

      # The mocked shape has coordinates: -71.1,42.1 -71.2,42.2 -71.3,42.3
      stop1 = insert(:gtfs_stop, %{lat: 42.1, lon: -71.1})
      stop2 = insert(:gtfs_stop, %{lat: 42.2, lon: -71.2})
      stop3 = insert(:gtfs_stop, %{lat: 42.15, lon: -71.15})
      stop4 = insert(:gtfs_stop, %{lat: 42.25, lon: -71.25})

      {:ok, _} =
        route0
        |> Arrow.Shuttles.Route.changeset(%{
          "shape_id" => shape.id,
          "route_stops" => [
            %{
              "direction_id" => "0",
              "stop_sequence" => "1",
              "display_stop_id" => stop1.id,
              "time_to_next_stop" => 30.0
            },
            %{
              "direction_id" => "0",
              "stop_sequence" => "2",
              "display_stop_id" => stop2.id
            }
          ]
        })
        |> Arrow.Repo.update()

      {:ok, _} =
        route1
        |> Arrow.Shuttles.Route.changeset(%{
          "shape_id" => shape.id,
          "route_stops" => [
            %{
              "direction_id" => "1",
              "stop_sequence" => "1",
              "display_stop_id" => stop3.id,
              "time_to_next_stop" => 30.0
            },
            %{
              "direction_id" => "1",
              "stop_sequence" => "2",
              "display_stop_id" => stop4.id
            }
          ]
        })
        |> Arrow.Repo.update()

      shuttle = Arrow.Shuttles.get_shuttle!(shuttle.id)

      changeset = Shuttle.changeset(shuttle, %{status: :active})

      assert %Ecto.Changeset{valid?: true} = changeset
    end

    test "skip stop distance validation when shape storage is disabled" do
      reassign_env(:shape_storage_enabled?, false)

      shape = shape_fixture()
      shuttle = shuttle_fixture()
      [route0, route1] = shuttle.routes

      [stop1, stop2, stop3, stop4] = insert_list(4, :gtfs_stop)

      {:ok, _} =
        route0
        |> Arrow.Shuttles.Route.changeset(%{
          "shape_id" => shape.id,
          "route_stops" => [
            %{
              "direction_id" => "0",
              "stop_sequence" => "1",
              "display_stop_id" => stop1.id,
              "time_to_next_stop" => 30.0
            },
            %{
              "direction_id" => "0",
              "stop_sequence" => "2",
              "display_stop_id" => stop2.id
            }
          ]
        })
        |> Arrow.Repo.update()

      {:ok, _} =
        route1
        |> Arrow.Shuttles.Route.changeset(%{
          "shape_id" => shape.id,
          "route_stops" => [
            %{
              "direction_id" => "1",
              "stop_sequence" => "1",
              "display_stop_id" => stop3.id,
              "time_to_next_stop" => 30.0
            },
            %{
              "direction_id" => "1",
              "stop_sequence" => "2",
              "display_stop_id" => stop4.id
            }
          ]
        })
        |> Arrow.Repo.update()

      shuttle = Arrow.Shuttles.get_shuttle!(shuttle.id)

      changeset = Shuttle.changeset(shuttle, %{status: :active})

      assert %Ecto.Changeset{valid?: true} = changeset
    end

    test "can save shuttle as draft/inactive regardless of stop distance from shape" do
      reassign_env(:shape_storage_enabled?, true)
      shape = s3_mocked_shape_fixture()

      shuttle = shuttle_fixture()
      [route0, route1] = shuttle.routes

      stop1 = insert(:gtfs_stop, %{lat: 42.0, lon: -71.1})
      stop2 = insert(:gtfs_stop, %{lat: 42.3, lon: -71.0})
      stop3 = insert(:gtfs_stop, %{lat: 42.2, lon: -71.1})
      stop4 = insert(:gtfs_stop, %{lat: 42.1, lon: -71.2})

      route0_attrs = %{
        "shape_id" => shape.id,
        "route_stops" => [
          %{
            "direction_id" => "0",
            "stop_sequence" => "1",
            "display_stop_id" => stop1.id,
            "time_to_next_stop" => 30.0
          },
          %{
            "direction_id" => "0",
            "stop_sequence" => "2",
            "display_stop_id" => stop2.id
          }
        ]
      }

      {:ok, _} =
        route0
        |> Arrow.Shuttles.Route.changeset(route0_attrs)
        |> Arrow.Repo.update()

      route1_attrs = %{
        "shape_id" => shape.id,
        "route_stops" => [
          %{
            "direction_id" => "1",
            "stop_sequence" => "1",
            "display_stop_id" => stop3.id,
            "time_to_next_stop" => 30.0
          },
          %{
            "direction_id" => "1",
            "stop_sequence" => "2",
            "display_stop_id" => stop4.id
          }
        ]
      }

      {:ok, _} =
        route1
        |> Arrow.Shuttles.Route.changeset(route1_attrs)
        |> Arrow.Repo.update()

      shuttle = Arrow.Shuttles.get_shuttle!(shuttle.id)

      draft_changeset =
        Shuttle.changeset(shuttle, %{
          status: :draft,
          routes: %{
            "0" => Map.put(route0_attrs, "id", route0.id),
            "1" => Map.put(route1_attrs, "id", route1.id)
          }
        })

      assert %Ecto.Changeset{valid?: true} = draft_changeset

      inactive_changeset =
        Shuttle.changeset(shuttle, %{
          status: :inactive,
          routes: %{
            "0" => Map.put(route0_attrs, "id", route0.id),
            "1" => Map.put(route1_attrs, "id", route1.id)
          }
        })

      assert %Ecto.Changeset{valid?: true} = inactive_changeset
    end
  end
end
