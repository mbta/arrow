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
                 id: 10,
                 published_revision: %Arrow.DisruptionRevision{
                   id: 9,
                   start_date: ~D[2020-10-05],
                   end_date: ~D[2020-10-08],
                   is_active: true,
                   adjustments: [
                     %Arrow.Adjustment{
                       id: 7935,
                       route_id: "CR-Fitchburg",
                       source: "gtfs_creator",
                       source_label: "FitchburgStopAtPorter"
                     }
                   ],
                   days_of_week: [
                     %Arrow.Disruption.DayOfWeek{
                       id: 21,
                       day_name: "monday",
                       end_time: ~T[15:00:00],
                       start_time: ~T[08:00:00]
                     },
                     %Arrow.Disruption.DayOfWeek{
                       id: 22,
                       day_name: "tuesday",
                       end_time: nil,
                       start_time: nil
                     },
                     %Arrow.Disruption.DayOfWeek{
                       id: 23,
                       day_name: "wednesday",
                       end_time: nil,
                       start_time: nil
                     },
                     %Arrow.Disruption.DayOfWeek{
                       id: 24,
                       day_name: "thursday",
                       end_time: nil,
                       start_time: nil
                     }
                   ],
                   exceptions: [
                     %Arrow.Disruption.Exception{
                       id: 10,
                       excluded_date: ~D[2020-10-07]
                     }
                   ],
                   trip_short_names: [
                     %Arrow.Disruption.TripShortName{
                       id: 33,
                       trip_short_name: "412"
                     }
                   ]
                 }
               }
             ] =
               Arrow.Repo.all(from d in Arrow.Disruption, order_by: d.id)
               |> Arrow.Repo.preload(published_revision: Arrow.DisruptionRevision.associations())

      assert [
               %Arrow.Adjustment{
                 route_id: "CR-Fitchburg",
                 source: "gtfs_creator",
                 source_label: "FitchburgStopAtPorter"
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
  end
end

defmodule Fake.HTTPoison do
  defmodule Happy do
    def start do
      {:ok, nil}
    end

    def get!(_, _) do
      %{
        status_code: 200,
        body:
          Jason.encode!(%{
            "adjustments" => [
              %{
                "id" => 7935,
                "inserted_at" => "2020-09-29T18:51:04.000000Z",
                "route_id" => "CR-Fitchburg",
                "source" => "gtfs_creator",
                "source_label" => "FitchburgStopAtPorter",
                "updated_at" => "2020-09-29T18:51:04.000000Z"
              }
            ],
            "disruption_adjustments" => [
              %{"adjustment_id" => 7935, "disruption_revision_id" => 9, "id" => 18}
            ],
            "disruption_day_of_weeks" => [
              %{
                "day_name" => "monday",
                "disruption_revision_id" => 9,
                "end_time" => "15:00:00.000000",
                "id" => 21,
                "inserted_at" => "2020-09-29T18:54:00.000000Z",
                "start_time" => "08:00:00.000000",
                "updated_at" => "2020-09-29T18:54:00.000000Z"
              },
              %{
                "day_name" => "tuesday",
                "disruption_revision_id" => 9,
                "end_time" => nil,
                "id" => 22,
                "inserted_at" => "2020-09-29T18:54:00.000000Z",
                "start_time" => nil,
                "updated_at" => "2020-09-29T18:54:00.000000Z"
              },
              %{
                "day_name" => "wednesday",
                "disruption_revision_id" => 9,
                "end_time" => nil,
                "id" => 23,
                "inserted_at" => "2020-09-29T18:54:00.000000Z",
                "start_time" => nil,
                "updated_at" => "2020-09-29T18:54:00.000000Z"
              },
              %{
                "day_name" => "thursday",
                "disruption_revision_id" => 9,
                "end_time" => nil,
                "id" => 24,
                "inserted_at" => "2020-09-29T18:54:00.000000Z",
                "start_time" => nil,
                "updated_at" => "2020-09-29T18:54:00.000000Z"
              }
            ],
            "disruption_exceptions" => [
              %{
                "disruption_revision_id" => 9,
                "excluded_date" => "2020-10-07",
                "id" => 10,
                "inserted_at" => "2020-09-29T18:54:00.000000Z",
                "updated_at" => "2020-09-29T18:54:00.000000Z"
              }
            ],
            "disruption_revisions" => [
              %{
                "disruption_id" => 10,
                "end_date" => "2020-10-08",
                "id" => 9,
                "inserted_at" => "2020-09-29T18:54:00.000000Z",
                "is_active" => true,
                "start_date" => "2020-10-05",
                "updated_at" => "2020-09-29T18:54:00.000000Z"
              }
            ],
            "disruption_trip_short_names" => [
              %{
                "disruption_revision_id" => 9,
                "id" => 33,
                "inserted_at" => "2020-09-29T18:54:00.000000Z",
                "trip_short_name" => "412",
                "updated_at" => "2020-09-29T18:54:00.000000Z"
              }
            ],
            "disruptions" => [
              %{
                "id" => 10,
                "inserted_at" => "2020-09-29T18:54:00.000000Z",
                "published_revision_id" => 9,
                "updated_at" => "2020-09-29T18:54:00.000000Z"
              }
            ]
          })
      }
    end
  end

  defmodule Sad.InvalidJson do
    def start do
      {:ok, nil}
    end

    def get!(_path, _) do
      %{status_code: 200, body: ""}
    end
  end

  defmodule Sad.Status401 do
    def start do
      {:ok, nil}
    end

    def get!(_path, _) do
      %{status_code: 401, body: %{}}
    end
  end
end
