defmodule Arrow.Repo.Migrations.CreateTrainsformerServiceDateDaysOfWeek do
  use Ecto.Migration

  def change do
    create table(:service_date_days_of_week) do
      add :day_name, :integer, null: false

      add :service_date_id,
          references(:trainsformer_service_dates, on_delete: :delete_all, validate: false)

      timestamps()
    end

    create index(:service_date_days_of_week, [:service_date_id]), concurrently: true
  end
end
