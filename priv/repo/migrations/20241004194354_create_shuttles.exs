defmodule Arrow.Repo.Migrations.CreateShuttles do
  use Ecto.Migration

  def change do
    create table(:shuttles) do
      add :shuttle_name, :string
      add :status, :string
      add :disrupted_route_id, references(:gtfs_routes, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:shuttles, [:shuttle_name])
    create index(:shuttles, [:disrupted_route_id])
  end
end
