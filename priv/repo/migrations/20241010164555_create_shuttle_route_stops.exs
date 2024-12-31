defmodule Arrow.Repo.Migrations.CreateShuttleRouteStops do
  use Ecto.Migration

  def change do
    create table(:shuttle_route_stops) do
      add :direction_id, :string
      add :stop_id, :string
      add :stop_sequence, :integer
      add :time_to_next_stop, :decimal
      add :shuttle_route_id, references(:shuttle_routes, on_delete: :nothing)

      timestamps(type: :timestamptz)
    end

    create index(:shuttle_route_stops, [:shuttle_route_id])
  end
end
