# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Arrow.Repo.insert!(%Arrow.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Arrow.Adjustment
alias Arrow.Disruption
alias Arrow.Repo

now = DateTime.truncate(DateTime.utc_now(), :second)

adjustments =
  "priv/repo/shuttles.json"
  |> File.read!()
  |> Jason.decode!()
  |> Enum.map(fn j ->
    %{
      inserted_at: now,
      updated_at: now,
      source: "gtfs_creator",
      source_label: j["id"],
      route_id: j["attributes"]["route_id"]
    }
  end)

Repo.insert_all(Adjustment, adjustments, on_conflict: :nothing)

for attrs <- [
      %{
        start_date: ~D[2019-12-20],
        end_date: ~D[2020-01-12],
        adjustments: [Repo.get_by!(Adjustment, source_label: "KenmoreReservoir")],
        exceptions: [~D[2019-12-29]],
        days_of_week: [
          %{day_name: "friday", start_time: ~T[20:45:00]},
          %{day_name: "saturday"},
          %{day_name: "sunday"}
        ]
      },
      %{
        start_date: ~D[2020-01-06],
        end_date: ~D[2020-01-17],
        adjustments: [Repo.get_by!(Adjustment, source_label: "KenmoreReservoir")],
        days_of_week: [
          %{day_name: "monday", start_time: ~T[20:45:00]},
          %{day_name: "tuesday", start_time: ~T[20:45:00]},
          %{day_name: "wednesday", start_time: ~T[20:45:00]},
          %{day_name: "thursday", start_time: ~T[20:45:00]},
          %{day_name: "friday", start_time: ~T[20:45:00]}
        ]
      },
      %{
        start_date: ~D[2020-01-11],
        end_date: ~D[2020-02-09],
        adjustments: [Repo.get_by!(Adjustment, source_label: "AlewifeHarvard")],
        days_of_week: [
          %{day_name: "saturday"},
          %{day_name: "sunday"}
        ]
      },
      %{
        start_date: ~D[2019-12-11],
        end_date: ~D[2020-03-29],
        adjustments: [Repo.get_by!(Adjustment, source_label: "ForgeParkReadville")],
        exceptions: [
          ~D[2019-12-28],
          ~D[2019-12-29],
          ~D[2020-01-04],
          ~D[2020-01-05]
        ],
        trip_short_names: [
          "1702",
          "1704",
          "1706",
          "1708",
          "1710",
          "1712",
          "1714",
          "2706",
          "2708",
          "2710",
          "2712",
          "2714",
          "1703",
          "1705",
          "1707",
          "1709",
          "1711",
          "1713",
          "1715",
          "1717",
          "2707",
          "2709",
          "2711",
          "2713",
          "2715",
          "2717"
        ],
        days_of_week: [
          %{day_name: "saturday"},
          %{day_name: "sunday"}
        ]
      },
      %{
        start_date: ~D[2019-12-11],
        end_date: ~D[2020-03-29],
        adjustments: [Repo.get_by!(Adjustment, source_label: "ForgeParkSouthStation")],
        exceptions: [
          ~D[2019-12-28],
          ~D[2019-12-29],
          ~D[2020-01-04],
          ~D[2020-01-05]
        ],
        trip_short_names: ["1716", "1718", "1719", "2716", "2718", "2719"],
        days_of_week: [
          %{day_name: "saturday"},
          %{day_name: "sunday"}
        ]
      }
    ] do
  Repo.insert!(Disruption.changeset(%Disruption{}, attrs))
end
