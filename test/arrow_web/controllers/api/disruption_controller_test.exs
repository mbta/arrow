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
    test "includes all revisions for all disruptions", %{conn: conn} do
      d1 = insert(:disruption)

      dr1 =
        insert(:disruption_revision,
          disruption: d1,
          start_date: ~D[2019-10-10],
          end_date: ~D[2019-11-01]
        )

      d2 = insert(:disruption)

      dr2 =
        insert(:disruption_revision,
          disruption: d2,
          start_date: ~D[2019-10-10],
          end_date: ~D[2019-11-01]
        )

      {:ok, new_d1} = Arrow.Disruption.update(dr1.id, %{end_date: ~D[2019-12-01]})
      :ok = Arrow.DisruptionRevision.ready_all!()

      new_d1 =
        Arrow.Disruption
        |> Arrow.Repo.get(new_d1.id)
        |> Arrow.Repo.preload([:revisions])

      new_d1
      |> Ecto.Changeset.change(%{published_revision_id: Enum.at(new_d1.revisions, -1).id})
      |> Arrow.Repo.update!()

      {:ok, _newer_d1} = Arrow.Disruption.update(dr1.id, %{end_date: ~D[2020-01-01]})

      res = json_response(get(conn, "/api/disruptions"), 200)

      assert %{
               "data" => data,
               "included" => included,
               "jsonapi" => %{"version" => "1.0"}
             } = res

      included_map = Map.new(included, fn inc -> {{inc["type"], inc["id"]}, inc} end)

      d1_data = Enum.find(data, &(&1["id"] == Integer.to_string(d1.id)))
      d2_data = Enum.find(data, &(&1["id"] == Integer.to_string(d2.id)))

      d1_ready_id = Integer.to_string(Enum.at(new_d1.revisions, -1).id)
      d2_ready_id = Integer.to_string(dr2.id)

      assert %{
               "id" => _,
               "relationships" => %{
                 "published_revision" => %{
                   "data" => %{
                     "id" => ^d1_ready_id,
                     "type" => "disruption_revision"
                   }
                 },
                 "ready_revision" => %{
                   "data" => %{
                     "id" => ^d1_ready_id,
                     "type" => "disruption_revision"
                   }
                 },
                 "revisions" => %{"data" => d1_revisions}
               },
               "type" => "disruption"
             } = d1_data

      d1_revision_ids =
        d1_revisions
        |> Enum.map(&String.to_integer(&1["id"]))
        |> Enum.sort()
        |> Enum.map(&Integer.to_string(&1))

      d1_revision1 = included_map[{"disruption_revision", Enum.at(d1_revision_ids, 0)}]
      d1_revision2 = included_map[{"disruption_revision", Enum.at(d1_revision_ids, 1)}]

      assert %{
               "attributes" => %{
                 "start_date" => "2019-10-10",
                 "end_date" => "2019-12-01",
                 "is_active" => true
               }
             } = d1_revision1

      assert %{
               "attributes" => %{
                 "start_date" => "2019-10-10",
                 "end_date" => "2020-01-01",
                 "is_active" => true
               }
             } = d1_revision2

      assert %{
               "id" => _,
               "relationships" => %{
                 "published_revision" => %{"data" => nil},
                 "ready_revision" => %{
                   "data" => %{
                     "id" => ^d2_ready_id,
                     "type" => "disruption_revision"
                   }
                 },
                 "revisions" => %{
                   "data" => [%{"id" => ^d2_ready_id, "type" => "disruption_revision"}]
                 }
               },
               "type" => "disruption"
             } = d2_data

      d2_revision1 = included_map[{"disruption_revision", d2_ready_id}]

      assert %{
               "attributes" => %{
                 "start_date" => "2019-10-10",
                 "end_date" => "2019-11-01",
                 "is_active" => true
               }
             } = d2_revision1
    end
  end

  describe "show/2" do
    @tag :authenticated
    test "returns valid disruption with all revisions from published on, in order", %{conn: conn} do
      d = insert(:disruption)

      dr =
        insert(:disruption_revision,
          disruption: d,
          start_date: ~D[2019-10-10],
          end_date: ~D[2019-11-01]
        )

      {:ok, new_disruption} = Arrow.Disruption.update(dr.id, %{end_date: ~D[2019-12-01]})

      :ok = Arrow.DisruptionRevision.ready_all!()

      new_disruption =
        Arrow.Disruption
        |> Arrow.Repo.get(new_disruption.id)
        |> Arrow.Repo.preload([:revisions])

      new_disruption
      |> Ecto.Changeset.change(%{published_revision_id: Enum.at(new_disruption.revisions, -1).id})
      |> Arrow.Repo.update!()

      {:ok, _newer_disruption} = Arrow.Disruption.update(dr.id, %{end_date: ~D[2020-01-01]})

      res =
        json_response(
          get(conn, "/api/disruptions/" <> Integer.to_string(d.id)),
          200
        )

      assert %{
               "data" => data,
               "included" => included,
               "jsonapi" => %{"version" => "1.0"}
             } = res

      ready_revision_id = Integer.to_string(new_disruption.ready_revision_id)

      assert %{
               "id" => _,
               "relationships" => %{
                 "published_revision" => %{
                   "data" => %{
                     "id" => ^ready_revision_id,
                     "type" => "disruption_revision"
                   }
                 },
                 "ready_revision" => %{
                   "data" => %{
                     "id" => ^ready_revision_id,
                     "type" => "disruption_revision"
                   }
                 },
                 "revisions" => %{"data" => d_revisions}
               },
               "type" => "disruption"
             } = data

      included_map = Map.new(included, fn inc -> {{inc["type"], inc["id"]}, inc} end)

      d_revision_ids =
        d_revisions
        |> Enum.map(&String.to_integer(&1["id"]))
        |> Enum.sort()
        |> Enum.map(&Integer.to_string(&1))

      d_revision1 = included_map[{"disruption_revision", Enum.at(d_revision_ids, 0)}]
      d_revision2 = included_map[{"disruption_revision", Enum.at(d_revision_ids, 1)}]

      assert %{
               "attributes" => %{
                 "start_date" => "2019-10-10",
                 "end_date" => "2019-12-01",
                 "is_active" => true
               }
             } = d_revision1

      assert %{
               "attributes" => %{
                 "start_date" => "2019-10-10",
                 "end_date" => "2020-01-01",
                 "is_active" => true
               }
             } = d_revision2
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

      assert %{
               "data" => %{
                 "attributes" => %{},
                 "id" => disruption_id,
                 "relationships" => %{
                   "published_revision" => %{"data" => nil},
                   "ready_revision" => %{"data" => nil},
                   "revisions" => %{
                     "data" => [
                       %{"id" => disruption_revision_id, "type" => "disruption_revision"}
                     ]
                   }
                 },
                 "type" => "disruption"
               },
               "included" => included,
               "jsonapi" => %{"version" => "1.0"}
             } = json_response(conn, 201)

      disruption_revision_response =
        Enum.find(
          included,
          &(&1["type"] == "disruption_revision" and &1["id"] == disruption_revision_id)
        )

      assert %{
               "attributes" => %{
                 "end_date" => "2019-11-01",
                 "is_active" => true,
                 "start_date" => "2019-11-01"
               }
             } = disruption_revision_response

      assert %Arrow.DisruptionRevision{
               start_date: ~D[2019-11-01],
               end_date: ~D[2019-11-01],
               is_active: true
             } = Repo.get!(Arrow.DisruptionRevision, String.to_integer(disruption_revision_id))
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
      |> Ecto.Changeset.change(%{ready_revision_id: disruption_revision.id})
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

      assert %{
               "data" => %{
                 "attributes" => %{},
                 "id" => disruption_id,
                 "relationships" => %{
                   "published_revision" => %{"data" => nil},
                   "ready_revision" => %{
                     "data" => %{"id" => dr1_id, "type" => "disruption_revision"}
                   },
                   "revisions" => %{
                     "data" => [
                       %{"id" => dr1_id, "type" => "disruption_revision"},
                       %{"id" => dr2_id, "type" => "disruption_revision"}
                     ]
                   }
                 },
                 "type" => "disruption"
               },
               "included" => included,
               "jsonapi" => %{"version" => "1.0"}
             } = json_response(conn, 200)

      dr1_response =
        Enum.find(
          included,
          &(&1["type"] == "disruption_revision" and &1["id"] == dr1_id)
        )

      dr2_response =
        Enum.find(
          included,
          &(&1["type"] == "disruption_revision" and &1["id"] == dr2_id)
        )

      assert %{
               "attributes" => %{
                 "end_date" => "2019-11-01",
                 "is_active" => true,
                 "start_date" => "2019-10-10"
               }
             } = dr1_response

      assert %{
               "attributes" => %{
                 "end_date" => "2019-12-01",
                 "is_active" => true,
                 "start_date" => "2019-10-10"
               }
             } = dr2_response

      assert %Arrow.DisruptionRevision{
               start_date: ~D[2019-10-10],
               end_date: ~D[2019-12-01],
               is_active: true
             } = Repo.get!(Arrow.DisruptionRevision, String.to_integer(dr2_id))
    end

    @tag :authenticated
    test "can update a disruption that's never been 'ready'", %{conn: conn} do
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
          days_of_week: [
            build(:day_of_week, day_name: DayOfWeek.date_to_day_name(~D[2019-10-10]))
          ],
          adjustments: [adjustment]
        )

      post_data = %{
        "data" => %{
          "type" => "disruption",
          "id" => disruption.id,
          "attributes" => %{
            "end_date" => Date.to_iso8601(~D[2019-12-01])
          }
        }
      }

      conn = patch(conn, "/api/disruptions/" <> Integer.to_string(disruption.id), post_data)

      assert %{
               "data" => %{
                 "relationships" => %{
                   "revisions" => %{
                     "data" => revisions
                   }
                 },
                 "type" => "disruption"
               },
               "included" => included
             } = json_response(conn, 200)

      assert length(revisions) == 2

      new_revision =
        Enum.find(
          included,
          &(&1["type"] == "disruption_revision" and &1["id"] != "#{disruption_revision.id}")
        )

      assert new_revision["attributes"]["end_date"] == "2019-12-01"
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
      |> Ecto.Changeset.change(%{ready_revision_id: disruption_revision.id})
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
      |> Ecto.Changeset.change(%{ready_revision_id: disruption_revision.id})
      |> Arrow.Repo.update!()

      conn = delete(conn, ArrowWeb.Router.Helpers.disruption_path(conn, :delete, disruption.id))

      response = response(conn, 204)

      assert response == ""

      new_disruption_revision =
        Arrow.Disruption
        |> Arrow.Repo.get!(disruption.id)
        |> Arrow.Repo.preload([:revisions])
        |> Map.get(:revisions)
        |> Enum.at(-1)

      refute new_disruption_revision.is_active
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
