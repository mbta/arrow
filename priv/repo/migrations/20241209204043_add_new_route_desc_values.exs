defmodule Arrow.Repo.Migrations.AddNewRouteDescValues do
  use Ecto.Migration

  # https://groups.google.com/g/massdotdevelopers/c/9130wr5gaBA

  def up do
    for {old, new} <- renames() do
      execute("ALTER TYPE route_desc RENAME VALUE '#{old}' TO '#{new}'")
    end
  end

  def down do
    for {old, new} <- renames() do
      execute("ALTER TYPE route_desc RENAME VALUE '#{new}' TO '#{old}'")
    end
  end

  defp renames do
    [
      {"Commuter Rail", "Regional Rail"},
      {"Community Bus", "Coverage Bus"},
      {"Key Bus", "Frequent Bus"}
    ]
  end
end
