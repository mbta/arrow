defmodule Arrow.Repo.Migrations.RemoveTripsRouteDirectionsNotNull do
  use Ecto.Migration

  def change do
    alter table(:hastus_trip_route_directions) do
      modify :via_variant, :string, null: true
    end
  end
end
