defmodule Arrow.Repo.Migrations.CreateDisruptionExceptions do
  use Ecto.Migration

  def change do
    create table(:disruption_exceptions) do
      add :excluded_date, :date, null: false
      add :disruption_id, references(:disruptions, on_delete: :delete_all)

      timestamps(type: :timestamptz)
    end

    create index(:disruption_exceptions, [:disruption_id])
  end
end
