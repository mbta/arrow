defmodule ArrowWeb.DisruptionApiControllerTest do
  use ArrowWeb.ConnCase, async: true
  alias Arrow.{Disruption, Repo}

  describe "index/2" do
    test "returns 200", %{conn: conn} do
      assert %{status: 200} = get(conn, "/api/disruptions")
    end

    test "includes all fields by default", %{conn: conn} do
      insert_disruptions()

      res = json_response(get(conn, "/api/disruptions"), 200)

      assert %{
               "data" => [
                 %{
                   "attributes" => %{
                     "end-date" => "2019-12-12",
                     "start-date" => "2019-10-10"
                   },
                   "relationships" => %{
                     "adjustments" => %{
                       "data" => [%{"type" => "adjustment-api"}]
                     },
                     "days-of-week" => %{},
                     "exceptions" => %{"data" => [%{"type" => "exception-api"}]},
                     "trip-short-names" => %{
                       "data" => [%{"type" => "trip-short-name-api"}]
                     }
                   },
                   "type" => "disruption-api"
                 },
                 %{
                   "attributes" => %{
                     "end-date" => "2019-12-30",
                     "start-date" => "2019-11-15"
                   },
                   "relationships" => %{
                     "adjustments" => %{
                       "data" => [%{"type" => "adjustment-api"}]
                     },
                     "days-of-week" => %{},
                     "exceptions" => %{},
                     "trip-short-names" => %{}
                   },
                   "type" => "disruption-api"
                 }
               ],
               "included" => [
                 %{
                   "attributes" => %{
                     "end-time" => nil,
                     "friday" => true,
                     "monday" => false,
                     "saturday" => false,
                     "start-time" => "20:30:00",
                     "sunday" => false,
                     "thursday" => false,
                     "tuesday" => false,
                     "wednesday" => false
                   },
                   "type" => "days-of-week-api"
                 },
                 %{
                   "attributes" => %{"excluded-date" => "2019-12-01"},
                   "type" => "exception-api"
                 },
                 %{
                   "attributes" => %{"trip-short-name" => "006"},
                   "type" => "trip-short-name-api"
                 },
                 %{
                   "attributes" => %{
                     "route-id" => "test_route_1",
                     "source" => "arrow",
                     "source-label" => "test_adjustment_1"
                   },
                   "type" => "adjustment-api"
                 },
                 %{
                   "attributes" => %{
                     "route-id" => "test_route_2",
                     "source" => "gtfs_creator",
                     "source-label" => "test_adjustment_2"
                   },
                   "type" => "adjustment-api"
                 }
               ],
               "jsonapi" => %{"version" => "1.0"}
             } = res
    end

    test "can include only specified relationships", %{conn: conn} do
      insert_disruptions()

      res = json_response(get(conn, "/api/disruptions", %{"include" => "adjustments"}), 200)

      assert assert %{
                      "data" => [
                        %{
                          "attributes" => %{
                            "end-date" => "2019-12-12",
                            "start-date" => "2019-10-10"
                          },
                          "relationships" => %{
                            "adjustments" => %{
                              "data" => [%{"type" => "adjustment-api"}]
                            },
                            "days-of-week" => %{},
                            "exceptions" => %{},
                            "trip-short-names" => %{}
                          },
                          "type" => "disruption-api"
                        },
                        %{
                          "attributes" => %{
                            "end-date" => "2019-12-30",
                            "start-date" => "2019-11-15"
                          },
                          "relationships" => %{
                            "adjustments" => %{
                              "data" => [%{"type" => "adjustment-api"}]
                            },
                            "days-of-week" => %{},
                            "exceptions" => %{},
                            "trip-short-names" => %{}
                          },
                          "type" => "disruption-api"
                        }
                      ],
                      "included" => [
                        %{
                          "attributes" => %{
                            "route-id" => "test_route_1",
                            "source" => "arrow",
                            "source-label" => "test_adjustment_1"
                          },
                          "type" => "adjustment-api"
                        },
                        %{
                          "attributes" => %{
                            "route-id" => "test_route_2",
                            "source" => "gtfs_creator",
                            "source-label" => "test_adjustment_2"
                          },
                          "type" => "adjustment-api"
                        }
                      ],
                      "jsonapi" => %{"version" => "1.0"}
                    } = res
    end

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

  defp insert_disruptions do
    {:ok, disruption_1} =
      Repo.insert(
        Disruption.changeset(%Disruption{}, %{
          start_date: ~D[2019-10-10],
          end_date: ~D[2019-12-12],
          adjustments: [
            %{
              source: "arrow",
              source_label: "test_adjustment_1",
              route_id: "test_route_1"
            }
          ],
          exceptions: [~D[2019-12-01]],
          trip_short_names: ["006"]
        })
      )

    {:ok, disruption_2} =
      Repo.insert(
        Disruption.changeset(%Disruption{}, %{
          start_date: ~D[2019-11-15],
          end_date: ~D[2019-12-30],
          days_of_week: [%{friday: true, start_time: ~T[20:30:00]}],
          adjustments: [
            %{
              source: "gtfs_creator",
              source_label: "test_adjustment_2",
              route_id: "test_route_2"
            }
          ]
        })
      )

    {disruption_1, disruption_2}
  end
end
