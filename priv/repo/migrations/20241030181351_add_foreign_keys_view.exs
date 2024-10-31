defmodule Arrow.Repo.Migrations.AddForeignKeysView do
  use Ecto.Migration

  def up do
    execute("""
    CREATE VIEW "foreign_key_constraints" AS
    SELECT
      pgc.conname AS name,
      pgc.conrelid::regclass::text AS origin_table,
      pgc.confrelid::regclass::text AS referenced_table,
      pg_get_constraintdef(pgc.oid, true) AS definition
    FROM pg_catalog.pg_constraint pgc
    WHERE pgc.contype = 'f'
    """)
  end

  def down do
    execute("""
    DROP VIEW "foreign_key_constraints"
    """)
  end
end
