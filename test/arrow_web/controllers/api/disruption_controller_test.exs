defmodule ArrowWeb.API.DisruptionControllerTest do
  use ArrowWeb.ConnCase
  alias Arrow.{Repo, Adjustment}
  alias Arrow.Disruption.DayOfWeek
  import Arrow.Factory

  describe "index/2" do
    @tag :authenticated
    test "returns 200", %{conn: conn} do
      assert %{status: 200} = get(conn, "/api/disruptions")
    end

    @tag :authenticated
    test "includes all fields by default", %{conn: conn} do
      d1 = insert(:disruption)

      dr1 =
        insert(:disruption_revision,
          disruption: d1,
          start_date: ~D[2019-10-10],
          end_date: ~D[2019-11-01],
          exceptions: [build(:exception)],
          trip_short_names: [build(:trip_short_name)]
        )

      d1 |> Ecto.Changeset.change(%{published_revision_id: dr1.id}) |> Arrow.Repo.update!()

      d2 = insert(:disruption)

      dr2 =
        insert(:disruption_revision,
          disruption: d2,
          start_date: ~D[2019-11-15],
          end_date: ~D[2019-12-01],
          trip_short_names: []
        )

      d2 |> Ecto.Changeset.change(%{published_revision_id: dr2.id}) |> Arrow.Repo.update!()

      res = json_response(get(conn, "/api/disruptions"), 200)

      assert %{
               "data" => data,
               "included" => included,
               "jsonapi" => %{"version" => "1.0"}
             } = res

      assert length(data) == 2

      d1 = Enum.find(data, &(&1["attributes"]["start_date"] == Date.to_string(dr1.start_date)))
      d2 = Enum.find(data, &(&1["attributes"]["start_date"] == Date.to_string(dr2.start_date)))

      end_date1 = Date.to_string(dr1.end_date)
      end_date2 = Date.to_string(dr2.end_date)

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

    @tag :authenticated
    test "includes latest revision by default", %{conn: conn} do
      d1 = insert(:disruption)

      dr1 =
        insert(:disruption_revision,
          disruption: d1,
          start_date: ~D[2019-10-10],
          end_date: ~D[2019-11-01]
        )

      d1 |> Ecto.Changeset.change(%{published_revision_id: dr1.id}) |> Arrow.Repo.update!()

      {:ok, _dr} = Arrow.Disruption.update(dr1.id, %{end_date: ~D[2019-12-01]})

      d2 = insert(:disruption)

      dr2 =
        insert(:disruption_revision,
          disruption: d2,
          start_date: ~D[2019-10-10],
          end_date: ~D[2019-11-01]
        )

      d2 |> Ecto.Changeset.change(%{published_revision_id: dr2.id}) |> Arrow.Repo.update!()

      res = json_response(get(conn, "/api/disruptions"), 200)

      assert %{
               "data" => data,
               "included" => included,
               "jsonapi" => %{"version" => "1.0"}
             } = res

      d1_data = Enum.find(data, &(&1["id"] == Integer.to_string(d1.id)))
      d2_data = Enum.find(data, &(&1["id"] == Integer.to_string(d2.id)))

      assert %{
               "attributes" => %{"end_date" => "2019-12-01", "start_date" => "2019-10-10"},
               "id" => _,
               "relationships" => %{},
               "type" => "disruption"
             } = d1_data

      assert %{
               "attributes" => %{"end_date" => "2019-11-01", "start_date" => "2019-10-10"},
               "id" => _,
               "relationships" => %{},
               "type" => "disruption"
             } = d2_data
    end

    @tag :authenticated
    test "includes latest revision when only_published flag is false", %{conn: conn} do
      d = insert(:disruption)

      dr =
        insert(:disruption_revision,
          disruption: d,
          start_date: ~D[2019-10-10],
          end_date: ~D[2019-11-01]
        )

      d |> Ecto.Changeset.change(%{published_revision_id: dr.id}) |> Arrow.Repo.update!()

      {:ok, _dr} = Arrow.Disruption.update(dr.id, %{end_date: ~D[2019-12-01]})

      res = json_response(get(conn, "/api/disruptions?only_published=false"), 200)

      assert %{
               "data" => data,
               "included" => included,
               "jsonapi" => %{"version" => "1.0"}
             } = res

      assert [
               %{
                 "attributes" => %{"end_date" => "2019-12-01", "start_date" => "2019-10-10"},
                 "id" => _,
                 "relationships" => %{},
                 "type" => "disruption"
               }
             ] = data
    end

    @tag :authenticated
    test "only returns published revision when parameter is given", %{conn: conn} do
      d = insert(:disruption)

      dr =
        insert(:disruption_revision,
          disruption: d,
          start_date: ~D[2019-10-10],
          end_date: ~D[2019-11-01]
        )

      d |> Ecto.Changeset.change(%{published_revision_id: dr.id}) |> Arrow.Repo.update!()

      {:ok, _dr} = Arrow.Disruption.update(dr.id, %{end_date: ~D[2019-12-01]})

      res = json_response(get(conn, "/api/disruptions?only_published=true"), 200)

      assert %{
               "data" => data,
               "included" => included,
               "jsonapi" => %{"version" => "1.0"}
             } = res

      assert [
               %{
                 "attributes" => %{"end_date" => "2019-11-01", "start_date" => "2019-10-10"},
                 "id" => _,
                 "relationships" => %{},
                 "type" => "disruption"
               }
             ] = data
    end

    @tag :authenticated
    test "fails when invalid only_published argument is given", %{conn: conn} do
      assert json_response(
               get(
                 conn,
                 "/api/disruptions/?only_published=foo"
               ),
               400
             )
    end

    @tag :authenticated
    test "can include only specified relationships", %{conn: conn} do
      d1 = insert(:disruption)

      dr1 =
        insert(:disruption_revision,
          disruption: d1,
          start_date: ~D[2019-10-10],
          end_date: ~D[2019-11-01],
          exceptions: [build(:exception)],
          trip_short_names: [build(:trip_short_name)]
        )

      d1 |> Ecto.Changeset.change(%{published_revision_id: dr1.id}) |> Arrow.Repo.update!()

      d2 = insert(:disruption)

      dr2 =
        insert(:disruption_revision,
          disruption: d2,
          start_date: ~D[2019-11-15],
          end_date: ~D[2019-12-01]
        )

      d2 |> Ecto.Changeset.change(%{published_revision_id: dr2.id}) |> Arrow.Repo.update!()

      res = json_response(get(conn, "/api/disruptions", %{"include" => "adjustments"}), 200)

      end_date1 = Date.to_string(dr1.end_date)
      end_date2 = Date.to_string(dr2.end_date)

      source_label1 = Enum.at(dr1.adjustments, 0).source_label
      source_label2 = Enum.at(dr2.adjustments, 0).source_label

      assert %{
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
                     "source_label" => ^source_label1
                   },
                   "type" => "adjustment"
                 },
                 %{
                   "attributes" => %{
                     "source_label" => ^source_label2
                   },
                   "type" => "adjustment"
                 }
               ],
               "jsonapi" => %{"version" => "1.0"}
             } = res
    end

    @tag :authenticated
    test "can filter by dates", %{conn: conn} do
      d1 = insert(:disruption)

      dr1 =
        insert(:disruption_revision,
          disruption: d1,
          start_date: ~D[2019-10-10],
          end_date: ~D[2019-11-01],
          exceptions: [build(:exception)],
          trip_short_names: [build(:trip_short_name)]
        )

      d1 |> Ecto.Changeset.change(%{published_revision_id: dr1.id}) |> Arrow.Repo.update!()

      d2 = insert(:disruption)

      dr2 =
        insert(:disruption_revision,
          disruption: d2,
          start_date: ~D[2019-11-15],
          end_date: ~D[2019-12-01]
        )

      d2 |> Ecto.Changeset.change(%{published_revision_id: dr2.id}) |> Arrow.Repo.update!()

      disruption_1_id = d1.id
      disruption_2_id = d2.id

      end_date1 = Date.to_string(dr1.end_date)
      end_date2 = Date.to_string(dr2.end_date)

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
      d1 = insert(:disruption)

      dr1 =
        insert(:disruption_revision,
          disruption: d1,
          start_date: ~D[2019-10-10],
          end_date: ~D[2019-11-01],
          exceptions: [build(:exception)],
          trip_short_names: [build(:trip_short_name)]
        )

      d1 |> Ecto.Changeset.change(%{published_revision_id: dr1.id}) |> Arrow.Repo.update!()

      assert %{"data" => %{"id" => disruption_1_id}} =
               json_response(
                 get(conn, "/api/disruptions/" <> Integer.to_string(d1.id), %{}),
                 200
               )
    end

    @tag :authenticated
    test "returns latest version of disruption by default", %{conn: conn} do
      d = insert(:disruption)

      dr =
        insert(:disruption_revision,
          disruption: d,
          start_date: ~D[2019-10-10],
          end_date: ~D[2019-11-01]
        )

      d |> Ecto.Changeset.change(%{published_revision_id: dr.id}) |> Arrow.Repo.update!()

      {:ok, _dr} = Arrow.Disruption.update(dr.id, %{end_date: ~D[2019-12-01]})

      assert %{"data" => %{"id" => _, "attributes" => %{"end_date" => "2019-12-01"}}} =
               json_response(
                 get(conn, "/api/disruptions/" <> Integer.to_string(d.id)),
                 200
               )

      assert %{"data" => %{"id" => _, "attributes" => %{"end_date" => "2019-12-01"}}} =
               json_response(
                 get(
                   conn,
                   "/api/disruptions/" <> Integer.to_string(d.id) <> "?only_published=false"
                 ),
                 200
               )
    end

    @tag :authenticated
    test "returns published version of disruption when paramater is given", %{conn: conn} do
      d = insert(:disruption)

      dr =
        insert(:disruption_revision,
          disruption: d,
          start_date: ~D[2019-10-10],
          end_date: ~D[2019-11-01]
        )

      d |> Ecto.Changeset.change(%{published_revision_id: dr.id}) |> Arrow.Repo.update!()

      {:ok, _dr} = Arrow.Disruption.update(dr.id, %{end_date: ~D[2019-12-01]})

      assert %{"data" => %{"id" => _, "attributes" => %{"end_date" => "2019-11-01"}}} =
               json_response(
                 get(
                   conn,
                   "/api/disruptions/" <> Integer.to_string(d.id) <> "?only_published=true"
                 ),
                 200
               )
    end

    @tag :authenticated
    test "fails when invalid only_published argument is given", %{conn: conn} do
      d = insert(:disruption)

      dr =
        insert(:disruption_revision,
          disruption: d,
          start_date: ~D[2019-10-10],
          end_date: ~D[2019-11-01]
        )

      d |> Ecto.Changeset.change(%{published_revision_id: dr.id}) |> Arrow.Repo.update!()

      assert json_response(
               get(
                 conn,
                 "/api/disruptions/" <> Integer.to_string(d.id) <> "?only_published=foo"
               ),
               400
             )
    end
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

      date = ~D[2019-11-01]
      iso_date = Date.to_iso8601(date)

      post_data = %{
        "data" => %{
          "type" => "disruption",
          "attributes" => %{
            "start_date" => iso_date,
            "end_date" => iso_date
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
                  "attributes" => %{"excluded_date" => iso_date}
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
      conn =
        post(conn, "/api/disruptions", %{
          "data" => %{
            "relationships" => %{
              "days_of_week" => %{
                "data" => [
                  %{
                    "type" => "day_of_week",
                    "attributes" => %{
                      "start_time" => "10:00:00",
                      "end_time" => "09:00:00",
                      "day_name" => "monday"
                    }
                  }
                ]
              },
              "trip_short_names" => %{
                "data" => [
                  %{
                    "type" => "trip_short_names",
                    "attributes" => %{"trip_short_name" => "shortname"}
                  },
                  %{
                    "type" => "trip_short_names",
                    "attributes" => %{"trip_short_name" => ""}
                  }
                ]
              }
            }
          }
        })

      assert resp = json_response(conn, 400)

      assert %{
               "errors" => [
                 %{"detail" => "Adjustments should have at least 1 item(s)"},
                 %{"detail" => "Days of week start time should be before end time"},
                 %{"detail" => "End date can't be blank"},
                 %{"detail" => "Start date can't be blank"},
                 %{"detail" => "Trip short name can't be blank"}
               ]
             } = resp
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
        insert(:adjustment, %{
          source_label: "test_adjustment_1",
          route_id: "test_route_1",
          source: "arrow"
        })

      disruption = insert(:disruption)

      disruption_revision =
        insert(:disruption_revision,
          disruption: disruption,
          start_date: ~D[2019-10-10],
          end_date: ~D[2019-11-01],
          exceptions: [build(:exception, excluded_date: ~D[2019-10-20])],
          days_of_week: [
            build(:day_of_week,
              day_name: DayOfWeek.date_to_day_name(~D[2019-10-10]),
              start_time: ~T[20:30:00]
            )
          ],
          trip_short_names: [build(:trip_short_name, trip_short_name: "006")],
          adjustments: [adjustment]
        )

      disruption
      |> Ecto.Changeset.change(%{published_revision_id: disruption_revision.id})
      |> Arrow.Repo.update!()

      post_data = %{
        "data" => %{
          "type" => "disruption",
          "id" => disruption.id,
          "attributes" => %{
            "start_date" => Date.to_iso8601(disruption_revision.start_date),
            "end_date" => Date.to_iso8601(~D[2019-12-01])
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
                  "id" => Enum.at(disruption_revision.trip_short_names, 0).id,
                  "attributes" => %{
                    "trip_short_name" =>
                      Enum.at(disruption_revision.trip_short_names, 0).trip_short_name
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
      adjustment =
        insert(:adjustment, %{
          source_label: "test_adjustment_1",
          route_id: "test_route_1",
          source: "arrow"
        })

      disruption = insert(:disruption)

      disruption_revision =
        insert(:disruption_revision,
          disruption: disruption,
          start_date: ~D[2019-10-10],
          end_date: ~D[2019-11-01],
          exceptions: [build(:exception, excluded_date: ~D[2019-10-20])],
          days_of_week: [
            build(:day_of_week,
              day_name: DayOfWeek.date_to_day_name(~D[2019-10-10]),
              start_time: ~T[20:30:00]
            )
          ],
          trip_short_names: [build(:trip_short_name, trip_short_name: "006")],
          adjustments: [adjustment]
        )

      disruption
      |> Ecto.Changeset.change(%{published_revision_id: disruption_revision.id})
      |> Arrow.Repo.update!()

      post_data = %{
        "data" => %{
          "type" => "disruption",
          "id" => disruption.id,
          "attributes" => %{
            "start_date" => "2019-10-10",
            "end_date" => "2019-11-10"
          },
          "relationships" => %{
            "days_of_week" => %{
              "data" => [
                %{
                  "type" => "day_of_week",
                  "id" => Enum.at(disruption_revision.days_of_week, 0).id,
                  "attributes" => %{
                    "start_time" => nil,
                    "end_time" => nil,
                    "day_name" => DayOfWeek.date_to_day_name(~D[2019-10-10])
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
                  "id" => Enum.at(disruption_revision.trip_short_names, 0).id,
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
                  "attributes" => %{"source_label" => adjustment.source_label}
                }
              ]
            }
          }
        }
      }

      conn = patch(conn, "/api/disruptions/" <> Integer.to_string(disruption.id), post_data)

      assert resp = json_response(conn, 400)
    end
  end

  describe "delete/2" do
    @tag :authenticated
    test "can delete a disruption", %{conn: conn} do
      disruption = insert(:disruption)

      disruption_revision =
        insert(:disruption_revision,
          disruption: disruption,
          start_date: ~D[2019-10-10],
          end_date: ~D[2019-11-01],
          exceptions: [build(:exception, excluded_date: ~D[2019-10-20])],
          days_of_week: [
            build(:day_of_week,
              day_name: DayOfWeek.date_to_day_name(~D[2019-10-10]),
              start_time: ~T[20:30:00]
            )
          ],
          trip_short_names: [build(:trip_short_name, trip_short_name: "006")]
        )

      disruption
      |> Ecto.Changeset.change(%{published_revision_id: disruption_revision.id})
      |> Arrow.Repo.update!()

      conn = delete(conn, ArrowWeb.Router.Helpers.disruption_path(conn, :delete, disruption.id))

      response = response(conn, 204)

      assert response == ""
    end

    @tag :authenticated
    test "returns 404 when no disruption by given ID exists", %{conn: conn} do
      conn = delete(conn, ArrowWeb.Router.Helpers.disruption_path(conn, :delete, 1))

      response = json_response(conn, 404)

      assert response["errors"] == [
               %{"detail" => "Not found"}
             ]
    end
  end
end
