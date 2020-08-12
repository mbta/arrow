defmodule Arrow.Repo.Migrations.ChangeDisruptionsToRevisions do
  use Ecto.Migration

  def up do
    rename_disruptions_to_disruption_revisions(:up)
    create_and_link_disruptions(:up)
  end

  def down do
    create_and_link_disruptions(:down)
    rename_disruptions_to_disruption_revisions(:down)
  end

  defp rename_disruptions_to_disruption_revisions(:up) do
    rename table(:disruptions), to: table(:disruption_revisions)
    rename table(:disruption_adjustments), :disruption_id, to: :disruption_revision_id
    rename table(:disruption_day_of_weeks), :disruption_id, to: :disruption_revision_id
    rename table(:disruption_exceptions), :disruption_id, to: :disruption_revision_id
    rename table(:disruption_trip_short_names), :disruption_id, to: :disruption_revision_id
  end

  defp rename_disruptions_to_disruption_revisions(:down) do
    rename table(:disruption_revisions), to: table(:disruptions)
    rename table(:disruption_adjustments), :disruption_revision_id, to: :disruption_id
    rename table(:disruption_day_of_weeks), :disruption_revision_id, to: :disruption_id
    rename table(:disruption_exceptions), :disruption_revision_id, to: :disruption_id
    rename table(:disruption_trip_short_names), :disruption_revision_id, to: :disruption_id
  end

  defp create_and_link_disruptions(:up) do
    create table(:disruptions) do
      add :published_revision_id, references(:disruption_revisions)
      timestamps(type: :timestamptz)
    end

    alter table(:disruption_revisions) do
      add :disruption_id, references(:disruptions)
      add :author, :string
      add :is_active, :boolean, default: true
    end

    execute """
    INSERT INTO disruptions (published_revision_id, inserted_at, updated_at)
      SELECT id, now(), now() FROM disruption_revisions
    """

    execute """
    UPDATE disruption_revisions
      SET disruption_id = disruptions.published_revision_id
      FROM disruptions
      WHERE disruption_revisions.id = disruptions.published_revision_id
    """

    alter table(:disruption_revisions) do
      modify :disruption_id, references(:disruptions, on_delete: :restrict),
        from: references(:disruptions),
        null: false
    end
  end

  defp create_and_link_disruptions(:down) do
    alter table(:disruption_revisions) do
      remove :disruption_id
      remove :author
      remove :is_active
    end

    drop table(:disruptions)
  end
end
