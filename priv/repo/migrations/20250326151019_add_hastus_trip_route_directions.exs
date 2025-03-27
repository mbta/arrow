defmodule Arrow.Repo.Migrations.AddHastusTripRouteDirections do
  use Ecto.Migration

  def change do
    create table(:hastus_trip_route_directions) do
      add :hastus_export_id, references(:hastus_exports, on_delete: :delete_all), null: false
      add :hastus_route_id, :string, null: false
      add :via_variant, :string, null: false
      add :avi_code, :string, null: false
      add :route_id, references(:gtfs_routes, on_delete: :delete_all, type: :string), null: false

      timestamps(type: :timestamptz)
    end
  end
end
