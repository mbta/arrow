defmodule Arrow.Repo.Migrations.ChangeDayOfWeekToEnum do
  use Ecto.Migration

  def up do
    execute("create type day_name as enum (
      'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'
    )")

    drop table(:disruption_day_of_weeks)

    create table("disruption_day_of_weeks") do
      add :day_name, :day_name, null: false
      add :start_time, :time
      add :end_time, :time
      add :disruption_id, references(:disruptions, on_delete: :delete_all), null: false

      timestamps(type: :timestamptz)
    end

    create index(:disruption_day_of_weeks, [:disruption_id])

    create unique_index(:disruption_day_of_weeks, [:disruption_id, :day_name],
             name: "unique_disruption_weekday"
           )
  end

  def down do
    drop table(:disruption_day_of_weeks)

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

    execute("drop type day_name")
  end
end
