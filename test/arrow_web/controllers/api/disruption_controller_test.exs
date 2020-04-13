defmodule ArrowWeb.API.DisruptionControllerTest do
  use ArrowWeb.ConnCase
  alias Arrow.{Disruption, Repo, Adjustment}

  describe "index/2" do
    @tag :authenticated
    test "returns 200", %{conn: conn} do
      assert %{status: 200} = get(conn, "/api/disruptions")
    end

    @tag :authenticated
    test "includes all fields by default", %{conn: conn} do
      insert_disruptions()

      res = json_response(get(conn, "/api/disruptions"), 200)

      assert %{
               "data" => data,
               "included" => included,
               "jsonapi" => %{"version" => "1.0"}
             } = res

      assert length(data) == 2

      d1 = Enum.find(data, &(&1["attributes"]["start_date"] == "2019-10-10"))
      d2 = Enum.find(data, &(&1["attributes"]["start_date"] == "2019-11-15"))

      assert %{
               "attributes" => %{"end_date" => "2019-12-12", "start_date" => "2019-10-10"},
               "id" => _,
               "relationships" => %{
                 "adjustments" => %{"data" => [%{"id" => id1, "type" => "adjustment"}]},
                 "days_of_week" => %{"data" => []},
                 "exceptions" => %{"data" => [%{"id" => id2, "type" => "exception"}]},
                 "trip_short_names" => %{"data" => [%{"id" => id3, "type" => "trip_short_name"}]}
               },
               "type" => "disruption"
             } = d1

      assert %{
               "attributes" => %{"end_date" => "2019-12-30", "start_date" => "2019-11-15"},
               "id" => _,
               "relationships" => %{
                 "adjustments" => %{"data" => [%{"id" => id4, "type" => "adjustment"}]},
                 "days_of_week" => %{"data" => [%{"id" => id5, "type" => "day_of_week"}]},
                 "exceptions" => %{"data" => []},
                 "trip_short_names" => %{"data" => []}
               },
               "type" => "disruption"
             } = d2

      assert length(included) == 5

      Enum.each([id1, id2, id3, id4, id5], fn id ->
        assert Enum.find(included, &(&1["id"] == id))
      end)
    end

    @tag :authenticated
    test "can include only specified relationships", %{conn: conn} do
      insert_disruptions()

      res = json_response(get(conn, "/api/disruptions", %{"include" => "adjustments"}), 200)

      assert assert %{
                      "data" => [
                        %{
                          "attributes" => %{
                            "end_date" => "2019-12-12",
                            "start_date" => "2019-10-10"
                          },
                          "relationships" => %{
                            "adjustments" => %{
                              "data" => [%{"type" => "adjustment"}]
                            },
                            "days_of_week" => %{},
                            "exceptions" => %{},
                            "trip_short_names" => %{}
                          },
                          "type" => "disruption"
                        },
                        %{
                          "attributes" => %{
                            "end_date" => "2019-12-30",
                            "start_date" => "2019-11-15"
                          },
                          "relationships" => %{
                            "adjustments" => %{
                              "data" => [%{"type" => "adjustment"}]
                            },
                            "days_of_week" => %{},
                            "exceptions" => %{},
                            "trip_short_names" => %{}
                          },
                          "type" => "disruption"
                        }
                      ],
                      "included" => [
                        %{
                          "attributes" => %{
                            "route_id" => "test_route_1",
                            "source" => "arrow",
                            "source_label" => "test_adjustment_1"
                          },
                          "type" => "adjustment"
                        },
                        %{
                          "attributes" => %{
                            "route_id" => "test_route_2",
                            "source" => "gtfs_creator",
                            "source_label" => "test_adjustment_2"
                          },
                          "type" => "adjustment"
                        }
                      ],
                      "jsonapi" => %{"version" => "1.0"}
                    } = res
    end

    @tag :authenticated
    test "can filter by dates", %{conn: conn} do
      {%{id: disruption_1_id}, %{id: disruption_2_id}} = insert_disruptions()

      Enum.each(
        [
          {"min_start_date", "2019-11-01", disruption_2_id},
          {"max_start_date", "2019-11-01", disruption_1_id},
          {"min_end_date", "2019-12-20", disruption_2_id},
          {"max_end_date", "2019-12-20", disruption_1_id}
        ],
        fn {filter, value, expected_id} ->
          data =
            json_response(
              get(conn, "/api/disruptions", %{"filter" => %{filter => value}}),
              200
            )["data"]

          assert Kernel.length(data) == 1
          assert List.first(data)["id"] == Integer.to_string(expected_id)
        end
      )
    end
  end

  describe "show/2" do
    @tag :authenticated
    test "returns valid disruption", %{conn: conn} do
      {disruption_1, _disruption_2} = insert_disruptions()
      disruption_1_id = disruption_1.id

      assert %{"data" => %{"id" => disruption_1_id}} =
               json_response(
                 get(conn, "/api/disruptions/" <> Integer.to_string(disruption_1_id), %{}),
                 200
               )
    end
  end

  defp insert_disruptions do
    {:ok, adjustment_1} =
      Repo.insert(
        Adjustment.changeset(%Adjustment{}, %{
          source: "arrow",
          source_label: "test_adjustment_1",
          route_id: "test_route_1"
        })
      )

    {:ok, disruption_1} =
      Repo.insert(
        Disruption.changeset_for_create(
          %Disruption{},
          %{
            "start_date" => ~D[2019-10-10],
            "end_date" => ~D[2019-12-12],
            "exceptions" => [%{"excluded_date" => ~D[2019-12-01]}],
            "trip_short_names" => [%{"trip_short_name" => "006"}]
          },
          [adjustment_1]
        )
      )

    {:ok, adjustment_2} =
      Repo.insert(
        Adjustment.changeset(%Adjustment{}, %{
          source: "gtfs_creator",
          source_label: "test_adjustment_2",
          route_id: "test_route_2"
        })
      )

    {:ok, disruption_2} =
      Repo.insert(
        Disruption.changeset_for_create(
          %Disruption{},
          %{
            "start_date" => ~D[2019-11-15],
            "end_date" => ~D[2019-12-30],
            "days_of_week" => [%{day_name: "friday", start_time: ~T[20:30:00]}]
          },
          [adjustment_2]
        )
      )

    {disruption_1, disruption_2}
  end

  describe "create/2" do
    setup %{conn: conn} do
      conn =
        conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> put_req_header("content-type", "application/vnd.api+json")

      {:ok, conn: conn}
    end

    @tag :authenticated
    test "creates a disruption when the data is present and valid", %{conn: conn} do
      {:ok, adjustment} =
        Repo.insert(%Adjustment{
          route_id: "Red",
          source: "gtfs_creator",
          source_label: "TheLabel"
        })

      post_data = %{
        "data" => %{
          "type" => "disruption",
          "attributes" => %{
            "start_date" => "2020-01-01",
            "end_date" => "2020-03-01"
          },
          "relationships" => %{
            "days_of_week" => %{
              "data" => [
                %{
                  "type" => "day_of_week",
                  "attributes" => %{
                    "start_time" => "10:00:00",
                    "end_time" => "23:00:00",
                    "day_name" => "monday"
                  }
                },
                %{
                  "type" => "day_of_week",
                  "attributes" => %{
                    "start_time" => "23:45:00",
                    "end_time" => nil,
                    "day_name" => "tuesday"
                  }
                }
              ]
            },
            "exceptions" => %{
              "data" => [
                %{"type" => "exception", "attributes" => %{"excluded_date" => "2020-02-01"}}
              ]
            },
            "trip_short_names" => %{
              "data" => [
                %{
                  "type" => "trip_short_names",
                  "attributes" => %{"trip_short_name" => "shortname"}
                }
              ]
            },
            "adjustments" => %{
              "data" => [
                %{
                  "type" => "adjustment",
                  "attributes" => %{"source_label" => adjustment.source_label}
                }
              ]
            }
          }
        }
      }

      conn = post(conn, "/api/disruptions", post_data)

      assert resp = json_response(conn, 201)
    end

    @tag :authenticated
    test "returns errors with invalid post", %{conn: conn} do
      conn = post(conn, "/api/disruptions", %{"data" => %{}})

      assert resp = json_response(conn, 400)
      assert %{"errors" => [_ | _]} = resp
    end
  end

  describe "update/2" do
    setup %{conn: conn} do
      conn =
        conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> put_req_header("content-type", "application/vnd.api+json")

      {:ok, conn: conn}
    end

    @tag :authenticated
    test "can update disruption with valid data", %{conn: conn} do
      {disruption_1, _} = insert_disruptions()

      post_data = %{
        "data" => %{
          "type" => "disruption",
          "id" => disruption_1.id,
          "attributes" => %{
            "start_date" => "2019-10-10",
            "end_date" => "2019-12-15"
          },
          "relationships" => %{
            "days_of_week" => %{
              "data" => [
                %{
                  "type" => "day_of_week",
                  "attributes" => %{
                    "start_time" => nil,
                    "end_time" => nil,
                    "day_name" => "saturday"
                  }
                }
              ]
            },
            "exceptions" => %{
              "data" => []
            },
            "trip_short_names" => %{
              "data" => [
                %{
                  "type" => "trip_short_names",
                  "id" => Enum.at(disruption_1.trip_short_names, 0).id,
                  "attributes" => %{
                    "trip_short_name" => Enum.at(disruption_1.trip_short_names, 0).trip_short_name
                  }
                }
              ]
            },
            "adjustments" => %{
              "data" => [
                %{
                  "type" => "adjustment",
                  "attributes" => %{"source_label" => "test_adjustment_1"}
                }
              ]
            }
          }
        }
      }

      conn = patch(conn, "/api/disruptions/" <> Integer.to_string(disruption_1.id), post_data)

      assert resp = json_response(conn, 200)
    end

    @tag :authenticated
    test "fails to update disruption with invalid data", %{conn: conn} do
      {disruption_1, _} = insert_disruptions()

      post_data = %{
        "data" => %{
          "type" => "disruption",
          "id" => disruption_1.id,
          "attributes" => %{
            "start_date" => "2019-10-10",
            "end_date" => "2019-12-15"
          },
          "relationships" => %{
            "days_of_week" => %{
              "data" => [
                %{
                  "type" => "day_of_week",
                  "attributes" => %{
                    "start_time" => nil,
                    "end_time" => nil,
                    "day_name" => "saturday"
                  }
                }
              ]
            },
            "exceptions" => %{
              "data" => []
            },
            "trip_short_names" => %{
              "data" => [
                %{
                  "type" => "trip_short_names",
                  "id" => Enum.at(disruption_1.trip_short_names, 0).id,
                  "attributes" => %{
                    "trip_short_name" => nil
                  }
                }
              ]
            },
            "adjustments" => %{
              "data" => [
                %{
                  "type" => "adjustment",
                  "attributes" => %{"source_label" => "test_adjustment_1"}
                }
              ]
            }
          }
        }
      }

      conn = patch(conn, "/api/disruptions/" <> Integer.to_string(disruption_1.id), post_data)

      assert resp = json_response(conn, 400)
    end
  end
end
