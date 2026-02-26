defmodule Arrow.Repo.Migrations.AddSeasonalFerryRouteDesc do
  # excellent_migrations:safety-assured-for-this-file raw_sql_executed

  use Ecto.Migration

  def up do
    execute("ALTER TYPE route_desc ADD VALUE 'Seasonal Ferry'")
  end
end
