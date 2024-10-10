defmodule Arrow.Repo.Migrations.CreateShuttleRoutes do
  use Ecto.Migration

  def change do
    create table(:shuttle_routes) do
      add :direction_id, :string
      add :direction_desc, :string
      add :destination, :string
      add :waypoint, :string
      add :suffix, :string
      add :shuttle_id, references(:shuttles, on_delete: :nothing)
      add :shape_id, references(:shapes, on_delete: :nothing)

      timestamps(type: :timestamptz)
    end

    create index(:shuttle_routes, [:shuttle_id])
    create index(:shuttle_routes, [:shape_id])
  end
end
