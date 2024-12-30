defmodule Arrow.Repo.Migrations.AddFkGtfsRouteShuttles do
  use Ecto.Migration

  def change do
    alter table(:shuttles) do
      modify :disrupted_route_id, references(:gtfs_routes, type: :varchar, on_delete: :nothing),
        from: :string
    end
  end
end
