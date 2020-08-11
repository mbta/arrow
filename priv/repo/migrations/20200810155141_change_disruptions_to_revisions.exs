defmodule Arrow.Repo.Migrations.ChangeDisruptionsToRevisions do
  use Ecto.Migration

  def up do
    rename_disruptions_to_disruption_revisions(:up)
    remove_updated_at_columns(:up)
    create_and_link_disruptions(:up)
    create_latest_revision_view(:up)
  end

  def down do
    create_latest_revision_view(:down)
    create_and_link_disruptions(:down)
    remove_updated_at_columns(:down)
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

  defp remove_updated_at_columns(:up) do
    alter table(:disruption_revisions), do: remove(:updated_at)
    alter table(:disruption_day_of_weeks), do: remove(:updated_at)
    alter table(:disruption_exceptions), do: remove(:updated_at)
    alter table(:disruption_trip_short_names), do: remove(:updated_at)
  end

  defp remove_updated_at_columns(:down) do
    alter table(:disruption_revisions), do: add(:updated_at, :timestamptz)
    alter table(:disruption_day_of_weeks), do: add(:updated_at, :timestamptz)
    alter table(:disruption_exceptions), do: add(:updated_at, :timestamptz)
    alter table(:disruption_trip_short_names), do: add(:updated_at, :timestamptz)

    execute "UPDATE disruption_revisions SET updated_at = inserted_at"
    execute "UPDATE disruption_day_of_weeks SET updated_at = inserted_at"
    execute "UPDATE disruption_exceptions SET updated_at = inserted_at"
    execute "UPDATE disruption_trip_short_names SET updated_at = inserted_at"

    alter table(:disruption_revisions), do: modify(:updated_at, :timestamptz, null: false)
    alter table(:disruption_day_of_weeks), do: modify(:updated_at, :timestamptz, null: false)
    alter table(:disruption_exceptions), do: modify(:updated_at, :timestamptz, null: false)
    alter table(:disruption_trip_short_names), do: modify(:updated_at, :timestamptz, null: false)
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

  defp create_latest_revision_view(:up) do
    execute """
    CREATE VIEW disruptions_with_latest_revisions AS
      SELECT *, (
        SELECT max(id) FROM disruption_revisions WHERE disruption_id = disruptions.id
      ) AS latest_revision_id
      FROM disruptions
    """
  end

  defp create_latest_revision_view(:down) do
    execute "DROP VIEW disruptions_with_latest_revisions"
  end
end
