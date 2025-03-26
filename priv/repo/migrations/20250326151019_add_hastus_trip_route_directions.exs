defmodule Arrow.Repo.Migrations.AddHastusTripRouteDirections do
  use Ecto.Migration

  def change do
    create table(:hastus_trip_route_directions) do
      add :hastus_export_id, references(:hastus_exports, on_delete: :delete_all)
      add :hastus_route_id, :string
      add :via_variant, :string
      add :avi_code, :string
      add :route_id, references(:gtfs_routes, on_delete: :delete_all, type: :string)

      timestamps(type: :timestamptz)
    end
  end
end
