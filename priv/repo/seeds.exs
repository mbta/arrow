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

Repo.insert_all(Adjustment, adjustments)
