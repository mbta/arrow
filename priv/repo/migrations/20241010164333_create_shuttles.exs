defmodule Arrow.Repo.Migrations.CreateShuttles do
  use Ecto.Migration

  def change do
    create table(:shuttles) do
      add :shuttle_name, :string
      add :disrupted_route_id, :string
      # add :disrupted_route_id, references(:gtfs_routes, type: :varchar, on_delete: :nothing)
      add :status, :string

      timestamps()
    end

    create unique_index(:shuttles, [:shuttle_name])
  end
end
