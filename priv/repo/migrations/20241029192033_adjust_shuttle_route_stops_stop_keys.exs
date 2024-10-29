defmodule Arrow.Repo.Migrations.AdjustShuttleRouteStopsStopKeys do
  use Ecto.Migration

  def change do
    alter table("shuttle_route_stops") do
      remove :stop_id, :string

      add :stop_id, references("stops")
      add :gtfs_stop_id, references("gtfs_stops", type: :string)

      constraint("shuttle_route_stops", :one_stop_id_must_be_non_null,
        check:
          "(stop_id IS NOT NULL AND gtfs_stop_id IS NULL) OR (stop_id IS NULL AND gtfs_stop_id IS NOT NULL)"
      )
    end
  end
end
