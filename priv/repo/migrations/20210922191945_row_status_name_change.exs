defmodule Arrow.Repo.Migrations.RowStatusNameChange do
  use Ecto.Migration

  def change do
    alter table(:disruption_revisions) do
      remove :row_confirmed
      add :row_approved, :boolean, null: false, default: true
    end
  end
end
