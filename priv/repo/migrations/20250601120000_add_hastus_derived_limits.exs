defmodule Arrow.Repo.Migrations.AddHastusDerivedLimits do
  use Ecto.Migration

  def change do
    create table(:hastus_derived_limits) do
      add :service_id, references(:hastus_services, on_delete: :delete_all), null: false

      add :start_stop_id, references(:gtfs_stops, type: :string), null: false
      add :end_stop_id, references(:gtfs_stops, type: :string), null: false

      timestamps(type: :timestamptz)
    end
  end
end
