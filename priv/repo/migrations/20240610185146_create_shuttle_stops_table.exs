defmodule Arrow.Repo.Migrations.CreateShuttleStopsTable do
  use Ecto.Migration

  def change do
    create table("stops") do
      add :stop_id, :string, null: false
      add :stop_name, :string, null: false
      add :stop_desc, :string, null: false
      add :platform_code, :string
      add :platform_name, :string
      add :stop_lat, :float, null: false
      add :stop_lon, :float, null: false
      add :stop_address, :string
      add :zone_id, :string
      add :level_id, :string
      add :parent_station, :string
      add :municipality, :string, null: false
      add :on_street, :string
      add :at_street, :string

      timestamps(type: :timestamptz)
    end
  end
end
