defmodule ArrowWeb.API.DisruptionControllerTest do
  use ArrowWeb.ConnCase
  alias Arrow.{Disruption, Repo, Adjustment}
  alias Arrow.Disruption.DayOfWeek

  @current_time DateTime.from_naive!(~N[2019-04-15 12:00:00], "America/New_York")

  def future_date() do
    {:ok, now} = DateTime.now(Application.get_env(:arrow, :time_zone))
    today = DateTime.to_date(now)
    Date.add(today, 10)
  end

  describe "index/2" do
    test "returns 200", %{conn: conn} do
      assert %{status: 200} = get(conn, "/api/disruptions")
    end

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

      end_date1 = Date.to_iso8601(future_date())
      end_date2 = future_date() |> Date.add(5) |> Date.to_iso8601()

      assert %{
               "attributes" => %{"end_date" => ^end_date1, "start_date" => "2019-10-10"},
               "id" => _,
               "relationships" => %{
                 "adjustments" => %{"data" => [%{"id" => id1, "type" => "adjustment"}]},
                 "days_of_week" => %{"data" => [%{"id" => id2, "type" => "day_of_week"}]},
                 "exceptions" => %{"data" => [%{"id" => id3, "type" => "exception"}]},
                 "trip_short_names" => %{"data" => [%{"id" => id4, "type" => "trip_short_name"}]}
               },
               "type" => "disruption"
             } = d1

      assert %{
               "attributes" => %{"end_date" => ^end_date2, "start_date" => "2019-11-15"},
               "id" => _,
               "relationships" => %{
                 "adjustments" => %{"data" => [%{"id" => id5, "type" => "adjustment"}]},
                 "days_of_week" => %{"data" => [%{"id" => id6, "type" => "day_of_week"}]},
                 "exceptions" => %{"data" => []},
                 "trip_short_names" => %{"data" => []}
               },
               "type" => "disruption"
             } = d2

      assert length(included) == 6

      Enum.each([id1, id2, id3, id4, id5, id6], fn id ->
        assert Enum.find(included, &(&1["id"] == id))
      end)
    end

    test "can include only specified relationships", %{conn: conn} do
      insert_disruptions()

      res = json_response(get(conn, "/api/disruptions", %{"include" => "adjustments"}), 200)

      end_date1 = Date.to_iso8601(future_date())
      end_date2 = future_date() |> Date.add(5) |> Date.to_iso8601()

      assert assert %{
                      "data" => [
                        %{
                          "attributes" => %{
                            "end_date" => ^end_date1,
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
                            "end_date" => ^end_date2,
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

    test "can filter by dates", %{conn: conn} do
      {%{id: disruption_1_id}, %{id: disruption_2_id}} = insert_disruptions()

      end_date1 = Date.to_iso8601(future_date())
      end_date2 = future_date() |> Date.add(5) |> Date.to_iso8601()

      Enum.each(
        [
          {"min_start_date", "2019-11-01", disruption_2_id},
          {"max_start_date", "2019-11-01", disruption_1_id},
          {"min_end_date", end_date2, disruption_2_id},
          {"max_end_date", end_date1, disruption_1_id}
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

  defp insert_adjustment(opts) do
    source_label = Keyword.get(opts, :source_label)
    route_id = Keyword.get(opts, :route_id)
    source = Keyword.get(opts, :source)

    Repo.insert!(
      Adjustment.changeset(%Adjustment{}, %{
        source: source,
        source_label: source_label,
        route_id: route_id
      })
    )
  end

  defp insert_disruption(opts) do
    start_date = Keyword.get(opts, :start_date)
    end_date = Keyword.get(opts, :end_date)

    exceptions =
      opts
      |> Keyword.get(:exceptions, [])
      |> Enum.map(&%{"excluded_date" => &1})

    trip_short_names =
      opts
      |> Keyword.get(:trip_short_names, [])
      |> Enum.map(&%{"trip_short_name" => &1})

    days_of_week =
      opts
      |> Keyword.get(:days_of_week, [])
      |> Enum.map(
        &%{
          day_name: Map.get(&1, :day_name),
          start_time: Map.get(&1, :start_time),
          end_time: Map.get(&1, :end_time)
        }
      )

    adjustments = Keyword.get(opts, :adjustments, [])
    current_time = Keyword.get(opts, :current_time)

    Repo.insert!(
      Disruption.changeset_for_create(
        %Disruption{},
        %{
          "start_date" => start_date,
          "end_date" => end_date,
          "exceptions" => exceptions,
          "trip_short_names" => trip_short_names,
          "days_of_week" => days_of_week
        },
        adjustments,
        current_time
      )
    )
  end

  defp insert_disruptions do
    adjustment_1 =
      insert_adjustment(
        source_label: "test_adjustment_1",
        route_id: "test_route_1",
        source: "arrow"
      )

    disruption_1 =
      insert_disruption(
        start_date: ~D[2019-10-10],
        end_date: future_date(),
        days_of_week: [
          %{day_name: DayOfWeek.date_to_day_name(future_date()), start_time: ~T[20:30:00]}
        ],
        exceptions: [future_date()],
        trip_short_names: ["006"],
        adjustments: [adjustment_1],
        current_time: @current_time
      )

    adjustment_2 =
      insert_adjustment(
        source_label: "test_adjustment_2",
        route_id: "test_route_2",
        source: "gtfs_creator"
      )

    disruption_2 =
      insert_disruption(
        start_date: ~D[2019-11-15],
        end_date: Date.add(future_date(), 5),
        days_of_week: [%{day_name: "friday", start_time: ~T[20:30:00]}],
        adjustments: [adjustment_2],
        current_time: @current_time
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

      date = future_date()
      future_iso_date = Date.to_iso8601(date)

      post_data = %{
        "data" => %{
          "type" => "disruption",
          "attributes" => %{
            "start_date" => future_iso_date,
            "end_date" => future_iso_date
          },
          "relationships" => %{
            "days_of_week" => %{
              "data" => [
                %{
                  "type" => "day_of_week",
                  "attributes" => %{
                    "start_time" => "10:00:00",
                    "end_time" => "23:00:00",
                    "day_name" => date |> Date.day_of_week() |> DayOfWeek.day_name()
                  }
                }
              ]
            },
            "exceptions" => %{
              "data" => [
                %{
                  "type" => "exception",
                  "attributes" => %{"excluded_date" => future_iso_date}
                }
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
      adjustment =
        insert_adjustment(
          source_label: "test_adjustment_1",
          route_id: "test_route_1",
          source: "arrow"
        )

      disruption =
        insert_disruption(
          start_date: future_date(),
          end_date: Date.add(future_date(), 7),
          exceptions: [future_date()],
          days_of_week: [
            %{day_name: DayOfWeek.date_to_day_name(future_date()), start_time: ~T[20:30:00]}
          ],
          trip_short_names: ["006"],
          adjustments: [adjustment],
          current_time: @current_time
        )

      post_data = %{
        "data" => %{
          "type" => "disruption",
          "id" => disruption.id,
          "attributes" => %{
            "start_date" => Date.to_iso8601(Date.add(future_date(), 1)),
            "end_date" => Date.to_iso8601(Date.add(future_date(), 8))
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
                  "id" => Enum.at(disruption.trip_short_names, 0).id,
                  "attributes" => %{
                    "trip_short_name" => Enum.at(disruption.trip_short_names, 0).trip_short_name
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

      conn = patch(conn, "/api/disruptions/" <> Integer.to_string(disruption.id), post_data)

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
            "end_date" => Date.to_iso8601(future_date())
          },
          "relationships" => %{
            "days_of_week" => %{
              "data" => [
                %{
                  "type" => "day_of_week",
                  "attributes" => %{
                    "start_time" => nil,
                    "end_time" => nil,
                    "day_name" => DayOfWeek.date_to_day_name(future_date())
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
