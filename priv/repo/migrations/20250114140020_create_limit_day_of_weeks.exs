defmodule Arrow.Repo.Migrations.CreateLimitDayOfWeeks do
  use Ecto.Migration

  def change do
    create table(:limit_day_of_weeks) do
      add :is_active, :boolean
      add :day_name, :string, null: false
      add :start_time, :time
      add :end_time, :time
      add :limit_id, references(:limits, on_delete: :delete_all)

      timestamps(type: :timestamptz)
    end

    create index(:limit_day_of_weeks, [:limit_id])
    create index(:limit_day_of_weeks, [:is_active])

    create unique_index(:limit_day_of_weeks, [:limit_id, :day_name], name: "unique_limit_weekday")
  end
end
