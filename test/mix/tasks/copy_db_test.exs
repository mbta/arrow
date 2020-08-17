defmodule Mix.Tasks.CopyDbTest do
  use Arrow.DataCase
  import ExUnit.CaptureLog

  setup do
    http_client = Application.get_env(:arrow, :http_client)
    on_exit(fn -> Application.put_env(:arrow, :http_client, http_client) end)
    :ok
  end

  describe "run/1" do
    def pre_populate_db do
      Arrow.Repo.delete_all(Arrow.Disruption)
      Arrow.Repo.delete_all(Arrow.Adjustment)

      # insert some existing data that should get blown away
      d1 = insert(:disruption, %{})
      d2 = insert(:disruption, %{})

      dr1 =
        insert(:disruption_revision, %{
          start_date: ~D[2020-01-01],
          end_date: ~D[2020-01-31],
          disruption: d1
        })

      dr2 =
        insert(:disruption_revision, %{
          start_date: ~D[2020-02-01],
          end_date: ~D[2020-02-28],
          disruption: d2
        })

      d1 |> Ecto.Changeset.change(%{published_revision_id: dr1.id}) |> Arrow.Repo.update!()
      d2 |> Ecto.Changeset.change(%{published_revision_id: dr2.id}) |> Arrow.Repo.update!()
    end

    test "replaces current database with values pulled from API" do
      Application.put_env(:arrow, :http_client, Fake.HTTPoison.Happy)
      pre_populate_db()

      Mix.Tasks.CopyDb.run([])

      assert [
               %Arrow.Disruption{
                 id: 1,
                 published_revision: %Arrow.DisruptionRevision{
                   adjustments: [],
                   days_of_week: [
                     %Arrow.Disruption.DayOfWeek{
                       day_name: "friday",
                       end_time: ~T[23:45:00],
                       start_time: ~T[20:45:00]
                     },
                     %Arrow.Disruption.DayOfWeek{
                       day_name: "saturday",
                       end_time: nil,
                       start_time: nil
                     },
                     %Arrow.Disruption.DayOfWeek{
                       day_name: "sunday",
                       end_time: nil,
                       start_time: nil
                     }
                   ],
                   end_date: ~D[2020-01-12],
                   exceptions: [
                     %Arrow.Disruption.Exception{
                       excluded_date: ~D[2019-12-29]
                     }
                   ],
                   start_date: ~D[2019-12-20],
                   trip_short_names: [
                     %Arrow.Disruption.TripShortName{
                       trip_short_name: "1702"
                     }
                   ]
                 }
               },
               %Arrow.Disruption{
                 published_revision: %Arrow.DisruptionRevision{
                   adjustments: [],
                   days_of_week: [
                     %Arrow.Disruption.DayOfWeek{
                       day_name: "thursday",
                       end_time: nil,
                       start_time: ~T[20:45:00]
                     },
                     %Arrow.Disruption.DayOfWeek{
                       day_name: "sunday",
                       end_time: nil,
                       start_time: ~T[20:45:00]
                     }
                   ],
                   end_date: ~D[2020-01-20],
                   exceptions: [],
                   start_date: ~D[2019-12-31],
                   trip_short_names: []
                 }
               }
             ] =
               Arrow.Repo.all(from d in Arrow.Disruption, order_by: d.id)
               |> Arrow.Repo.preload(
                 published_revision: [:adjustments, :days_of_week, :exceptions, :trip_short_names]
               )

      assert [
               %Arrow.Adjustment{
                 route_id: "Green-D",
                 source: "gtfs_creator",
                 source_label: "KenmoreReservoir"
               },
               %Arrow.Adjustment{
                 route_id: "Orange",
                 source: "gtfs_creator",
                 source_label: "ForestHillsJacksonSquare"
               },
               %Arrow.Adjustment{
                 route_id: "Blue",
                 source: "gtfs_creator",
                 source_label: "OrientHeightsWonderland"
               }
             ] = Arrow.Repo.all(Arrow.Adjustment)
    end

    test "handles invalid JSON" do
      Application.put_env(:arrow, :http_client, Fake.HTTPoison.Sad.InvalidJson)

      log =
        capture_log(fn ->
          Mix.Tasks.CopyDb.run([])
        end)

      assert log =~ "invalid JSON"
    end

    test "handles non 200 status code" do
      Application.put_env(:arrow, :http_client, Fake.HTTPoison.Sad.Status401)

      log =
        capture_log(fn ->
          Mix.Tasks.CopyDb.run([])
        end)

      assert log =~ "issue with request: 401"
    end

    test "does not alter database if transaction fails" do
      Application.put_env(:arrow, :http_client, Fake.HTTPoison.Sad.InvalidData)
      pre_populate_db()

      initial_adjustments = Arrow.Repo.all(Arrow.Adjustment)

      initial_disruptions =
        Arrow.Repo.all(Arrow.Disruption)
        |> Arrow.Repo.preload(
          published_revision: [:adjustments, :days_of_week, :exceptions, :trip_short_names]
        )

      log =
        capture_log(fn ->
          Mix.Tasks.CopyDb.run([])
        end)

      assert log =~
               "[error] Error inserting data: null value in column \"day_name\" violates not-null constraint"

      assert initial_adjustments == Arrow.Repo.all(Arrow.Adjustment)

      assert initial_disruptions ==
               Arrow.Repo.all(Arrow.Disruption)
               |> Arrow.Repo.preload(
                 published_revision: [:adjustments, :days_of_week, :exceptions, :trip_short_names]
               )
    end
  end
end

defmodule Fake.HTTPoison do
  defmodule Happy do
    def start() do
      {:ok, nil}
    end

    def get!(path, _) do
      entities = path |> String.split("/") |> Enum.at(-1)
      get_entities(entities)
    end

    defp get_entities("disruptions") do
      %{
        status_code: 200,
        body:
          Jason.encode!(%{
            data: [
              %{
                attributes: %{end_date: "2020-01-12", start_date: "2019-12-20"},
                id: "1",
                relationships: %{
                  adjustments: %{
                    data: [
                      %{id: "12", type: "adjustment"},
                      %{id: "13", type: "adjustment"}
                    ]
                  },
                  days_of_week: %{
                    data: [
                      %{id: "1", type: "day_of_week"},
                      %{id: "2", type: "day_of_week"},
                      %{id: "3", type: "day_of_week"}
                    ]
                  },
                  exceptions: %{data: [%{id: "1", type: "exception"}]},
                  trip_short_names: %{data: [%{id: "1", type: "trip_short_name"}]}
                },
                type: "disruption"
              },
              %{
                attributes: %{end_date: "2020-01-20", start_date: "2019-12-31"},
                id: "2",
                relationships: %{
                  adjustments: %{data: [%{id: "13", type: "adjustment"}]},
                  days_of_week: %{
                    data: [
                      %{id: "4", type: "day_of_week"},
                      %{id: "6", type: "day_of_week"}
                    ]
                  },
                  exceptions: %{data: []},
                  trip_short_names: %{data: []}
                },
                type: "disruption"
              }
            ],
            included: [
              %{attributes: %{trip_short_name: "1702"}, id: "1", type: "trip_short_name"},
              %{
                attributes: %{day_name: "friday", end_time: "23:45:00", start_time: "20:45:00"},
                id: "1",
                type: "day_of_week"
              },
              %{
                attributes: %{day_name: "saturday", end_time: nil, start_time: nil},
                id: "2",
                type: "day_of_week"
              },
              %{
                attributes: %{day_name: "sunday", end_time: nil, start_time: nil},
                id: "3",
                type: "day_of_week"
              },
              %{
                attributes: %{day_name: "thursday", end_time: nil, start_time: "20:45:00"},
                id: "4",
                type: "day_of_week"
              },
              %{
                attributes: %{day_name: "sunday", end_time: nil, start_time: "20:45:00"},
                id: "6",
                type: "day_of_week"
              },
              %{attributes: %{trip_short_name: "1702"}, id: "1", type: "trip_short_name"},
              %{attributes: %{excluded_date: "2019-12-29"}, id: "1", type: "exception"},
              %{
                attributes: %{
                  route_id: "Green-D",
                  source: "gtfs_creator",
                  source_label: "KenmoreReservoir"
                },
                id: "12",
                type: "adjustment"
              },
              %{
                attributes: %{
                  route_id: "Orange",
                  source: "gtfs_creator",
                  source_label: "ForestHillsJacksonSquare"
                },
                id: "13",
                type: "adjustment"
              }
            ]
          })
      }
    end

    defp get_entities("adjustments") do
      %{
        status_code: 200,
        body:
          Jason.encode!(%{
            data: [
              %{
                attributes: %{
                  route_id: "Green-D",
                  source: "gtfs_creator",
                  source_label: "KenmoreReservoir"
                },
                id: "12",
                type: "adjustment"
              },
              %{
                attributes: %{
                  route_id: "Orange",
                  source: "gtfs_creator",
                  source_label: "ForestHillsJacksonSquare"
                },
                id: "13",
                type: "adjustment"
              },
              %{
                attributes: %{
                  route_id: "Blue",
                  source: "gtfs_creator",
                  source_label: "OrientHeightsWonderland"
                },
                id: "15",
                type: "adjustment"
              }
            ]
          })
      }
    end

    defp get_entities(_) do
      []
    end
  end

  defmodule Sad.InvalidData do
    def start() do
      {:ok, nil}
    end

    def get!(path, _) do
      entities = path |> String.split("/") |> Enum.at(-1)
      get_entities(entities)
    end

    defp get_entities("disruptions") do
      %{
        status_code: 200,
        body:
          Jason.encode!(%{
            data: [
              %{
                attributes: %{end_date: "2020-01-12", start_date: "2019-12-20"},
                id: "1",
                relationships: %{
                  adjustments: %{
                    data: [
                      %{id: "12", type: "adjustment"}
                    ]
                  },
                  days_of_week: %{
                    data: [
                      %{id: "1", type: "day_of_week"},
                      %{id: "2", type: "day_of_week"},
                      %{id: "3", type: "day_of_week"}
                    ]
                  },
                  exceptions: %{data: []},
                  trip_short_names: %{data: []}
                },
                type: "disruption"
              }
            ],
            included: [
              %{attributes: %{trip_short_name: "1702"}, id: "1", type: "trip_short_name"},
              %{
                attributes: %{end_time: nil, start_time: "20:45:00"},
                id: "1",
                type: "day_of_week"
              },
              %{
                attributes: %{day_name: "saturday", end_time: nil, start_time: nil},
                id: "2",
                type: "day_of_week"
              },
              %{
                attributes: %{day_name: "sunday", end_time: nil, start_time: nil},
                id: "3",
                type: "day_of_week"
              },
              %{
                attributes: %{
                  route_id: "Green-D",
                  source: "gtfs_creator",
                  source_label: "KenmoreReservoir"
                },
                id: "12",
                type: "adjustment"
              }
            ]
          })
      }
    end

    defp get_entities("adjustments") do
      %{
        status_code: 200,
        body:
          Jason.encode!(%{
            data: [
              %{
                attributes: %{
                  route_id: "Green-D",
                  source: "gtfs_creator",
                  source_label: "KenmoreReservoir"
                },
                id: "12",
                type: "adjustment"
              }
            ]
          })
      }
    end
  end

  defmodule Sad.InvalidJson do
    def start() do
      {:ok, nil}
    end

    def get!(_path, _) do
      %{status_code: 200, body: ""}
    end
  end

  defmodule Sad.Status401 do
    def start() do
      {:ok, nil}
    end

    def get!(_path, _) do
      %{status_code: 401, body: %{}}
    end
  end
end
