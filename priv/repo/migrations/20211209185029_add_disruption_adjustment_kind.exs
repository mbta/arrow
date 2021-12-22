defmodule Arrow.Repo.Migrations.AddDisruptionAdjustmentKind do
  use Ecto.Migration

  def change do
    alter table(:disruption_revisions) do
      add :adjustment_kind, :string
    end
  end
end
