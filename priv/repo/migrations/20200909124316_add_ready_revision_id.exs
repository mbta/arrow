defmodule Arrow.Repo.Migrations.AddReadyRevisionId do
  use Ecto.Migration

  def change do
    alter table(:disruptions) do
      add :ready_revision_id, references(:disruption_revisions)
    end

    execute(&execute_up/0, &execute_down/0)
  end

  defp execute_up do
    repo().query!("UPDATE disruptions SET ready_revision_id = published_revision_id")
  end

  defp execute_down do
    repo().query!("UPDATE disruptions SET published_revision_id = ready_revision_id")
  end
end
