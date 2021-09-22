defmodule Arrow.Repo.Migrations.AddRowStatus do
  use Ecto.Migration

  def change do
    alter table(:disruption_revisions) do
      add :row_confirmed, :boolean, null: false, default: true
    end
  end
end
