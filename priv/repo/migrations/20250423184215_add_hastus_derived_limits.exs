defmodule Arrow.Repo.Migrations.AddHastusDerivedLimits do
  use Ecto.Migration

  def change do
    create table(:hastus_derived_limits) do
      add :export_id, references(:hastus_exports, on_delete: :delete_all), null: false

      add :start_stop_id, references(:gtfs_stops, type: :string), null: false
      add :end_stop_id, references(:gtfs_stops, type: :string), null: false

      add :start_date, :date, null: false
      add :end_date, :date, null: false

      add :service_name, :string, null: false

      # Does it need this?
      timestamps(type: :timestamptz)
    end
  end
end
