defmodule Arrow.Repo.Migrations.AddLimitExclusionConstraint do
  use Ecto.Migration

  def change do
    alter table(:limits) do
      add :check_for_overlap, :boolean
    end

    execute "update limits set check_for_overlap = false", ""

    execute "alter table limits alter column check_for_overlap set default true",
            "alter table limits alter column check_for_overlap drop default"

    execute "alter table limits alter column check_for_overlap set not null",
            "alter table limits alter column check_for_overlap drop not null"

    execute "create extension if not exists btree_gist",
            "drop extension if exists btree_gist"

    create constraint(:limits, :no_overlap,
             exclude: """
             gist (
               disruption_id with =,
               route_id with =,
               least(start_stop_id, end_stop_id) with =,
               greatest(start_stop_id, end_stop_id) with =,
               daterange(start_date, end_date, '[]') with &&
             ) where (check_for_overlap = true)
             """
           )
  end
end
