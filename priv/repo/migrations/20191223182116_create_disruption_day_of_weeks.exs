defmodule Arrow.Repo.Migrations.CreateDisruptionDayOfWeeks do
  use Ecto.Migration

  def change do
    create table(:disruption_day_of_weeks) do
      add :monday, :boolean, default: false, null: false
      add :tuesday, :boolean, default: false, null: false
      add :wednesday, :boolean, default: false, null: false
      add :thursday, :boolean, default: false, null: false
      add :friday, :boolean, default: false, null: false
      add :saturday, :boolean, default: false, null: false
      add :sunday, :boolean, default: false, null: false
      add :start_time, :time
      add :end_time, :time
      add :disruption_id, references(:disruptions, on_delete: :delete_all)

      timestamps(type: :timestamptz)
    end

    create index(:disruption_day_of_weeks, [:disruption_id])
  end
end
