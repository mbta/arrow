defmodule Arrow.Repo.Migrations.AddDisruptionRevisionDescription do
  use Ecto.Migration

  def change do
    alter table(:disruption_revisions) do
      add(:description, :text)
    end

    execute(&execute_up/0, &execute_down/0)

    alter table(:disruption_revisions) do
      modify :description, :text, from: :text, null: false
    end
  end

  def execute_up do
    repo().query!("""
    UPDATE disruption_revisions dr
    SET description = (SELECT string_agg(a.source_label, ', ')
                       FROM disruption_revisions d
                       JOIN disruption_adjustments da
                       ON d.id = da.disruption_revision_id
                       JOIN adjustments a
                       ON da.adjustment_id = a.id
                       WHERE dr.id = d.id
                       GROUP BY d.id)
    """)
  end

  def execute_down, do: nil
end
