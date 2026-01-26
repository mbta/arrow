defmodule Arrow.Repo.Migrations.CreateTrainsformerServiceDateDaysOfWeek do
  use Ecto.Migration

  def change do
    create table(:service_date_days_of_week) do
      add :day_name, :integer, null: false

      # excellent_migrations:safety-assured-for-next-line column_reference_added
      add :service_date_id,
          references(:trainsformer_service_dates, on_delete: :delete_all, on_update: :update_all)

      timestamps()
    end

    # concurrent index creation not needed here since the column + table are empty
    # excellent_migrations:safety-assured-for-next-line index_not_concurrently
    create index(:service_date_days_of_week, [:service_date_id])
  end
end
