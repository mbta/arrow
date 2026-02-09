defmodule Arrow.Repo.Migrations.ArchivedStatus do
  use Ecto.Migration

  def up do
    alter table(:disruptionsv2) do
      add :status, :string
    end

    execute "UPDATE disruptionsv2 SET status = CASE
      WHEN is_active THEN 'approved'
      ELSE 'pending'
    END",
            ""

    alter table(:disruptionsv2) do
      remove :is_active
    end
  end

  def down do
    alter table(:disruptionsv2) do
      add :is_active, :boolean, default: true
    end

    execute "UPDATE disruptionsv2 SET is_active = CASE
      WHEN status = 'approved' THEN true
      ELSE false
    END",
            ""

    alter table(:disruptionsv2) do
      remove :status
    end
  end
end
