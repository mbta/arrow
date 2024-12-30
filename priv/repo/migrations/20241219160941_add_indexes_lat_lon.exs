defmodule Arrow.Repo.Migrations.AddIndexesLatLon do
  use Ecto.Migration

  def change do
    create index(:gtfs_stops, [:lat, :lon, :vehicle_type, :id])
    create index(:stops, [:stop_lat, :stop_lon, :stop_id])
  end
end
