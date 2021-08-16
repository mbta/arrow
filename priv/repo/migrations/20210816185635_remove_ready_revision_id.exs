defmodule Arrow.Repo.Migrations.RemoveReadyRevisionId do
  use Ecto.Migration

  def change do
    execute(&execute_up/0, &execute_down/0)

    alter table(:disruptions) do
      remove :ready_revision_id, references(:disruption_revisions)
    end
  end

  defp execute_up, do: nil

  defp execute_down do
    repo().query!("UPDATE disruptions SET ready_revision_id = published_revision_id")
  end
end
