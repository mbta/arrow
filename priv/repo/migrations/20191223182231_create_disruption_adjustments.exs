defmodule Arrow.Repo.Migrations.CreateDisruptionAdjustments do
  use Ecto.Migration

  def change do
    create table(:disruption_adjustments) do
      add :disruption_id, references(:disruptions, on_delete: :delete_all)
      add :adjustment_id, references(:adjustments, on_delete: :nothing)
    end

    create index(:disruption_adjustments, [:disruption_id])
    create index(:disruption_adjustments, [:adjustment_id])
  end
end
