defmodule Arrow.Repo.Migrations.AddNewRouteDescValues do
  use Ecto.Migration

  import Ecto.Query
  import Arrow.Gtfs.MigrationHelper

  # https://groups.google.com/g/massdotdevelopers/c/9130wr5gaBA
  # For now, we're simply adding the new values without removing the old ones.
  # We can remove the old values when we've fully switched over to using the new ones.

  def up do
    for {_old, new} <- renames() do
      execute("ALTER TYPE route_desc ADD VALUE '#{new}'")
    end
  end

  def down do
    # Postgres doesn't support removing values from an enum,
    # so we need to use a more manual workaround.

    # Rename the current type for the sake of clarity.
    execute("ALTER TYPE route_desc RENAME TO route_desc_v2")

    # 1. Rename all instances of route_desc_v2 using a v2-only value, to use the corresponding v1 value.
    for {old, new} <- renames() do
      from(r in Arrow.Gtfs.Route, where: r.desc == ^new, update: [set: [desc: ^old]])
      |> Arrow.Repo.update_all([])
    end

    # 2. Create a new enum type containing only the v1 values.
    create_enum_type("route_desc_v1", [
      "Commuter Rail",
      "Rapid Transit",
      "Local Bus",
      "Key Bus",
      "Supplemental Bus",
      "Community Bus",
      "Commuter Bus",
      "Ferry",
      "Rail Replacement Bus"
    ])

    # 3. Convert gtfs_routes.desc to route_desc_v1 type.
    execute("""
    ALTER TABLE gtfs_routes ALTER COLUMN "desc" TYPE route_desc_v1  USING ("desc"::text::route_desc_v1)
    """)

    # 4. Delete the original route_desc type.
    execute("DROP TYPE route_desc_v2")

    # 5. Rename the new type to the old one.
    execute("ALTER TYPE route_desc_v1 RENAME TO route_desc")

    # Recommended by Postgres docs after altering a column's data type.
    execute("ANALYZE gtfs_routes")
  end

  defp renames do
    [
      {"Commuter Rail", "Regional Rail"},
      {"Community Bus", "Coverage Bus"},
      {"Key Bus", "Frequent Bus"}
    ]
  end
end
