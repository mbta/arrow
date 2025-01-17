defmodule Arrow.Repo.Migrations.CreateLimits do
  use Ecto.Migration

  def change do
    create table(:limits) do
      add :start_date, :date
      add :end_date, :date
      add :disruption_id, references(:disruptionsv2, on_delete: :nothing)
      add :route_id, references(:gtfs_routes, type: :varchar, on_delete: :nothing)
      add :start_stop_id, references(:gtfs_stops, type: :varchar, on_delete: :nothing)
      add :end_stop_id, references(:gtfs_stops, type: :varchar, on_delete: :nothing)

      timestamps(type: :timestamptz)
    end

    create index(:limits, [:disruption_id])
    create index(:limits, [:route_id])
    create index(:limits, [:start_stop_id])
    create index(:limits, [:end_stop_id])
  end
end
