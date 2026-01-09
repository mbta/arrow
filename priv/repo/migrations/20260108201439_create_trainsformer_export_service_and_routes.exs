defmodule Arrow.Repo.Migrations.CreateTrainsformerExportServiceAndRoutes do
  use Ecto.Migration

  def change do
    create table(:trainsformer_services) do
      add :name, :string
      add :export_id, references(:trainsformer_exports, on_delete: :nothing)

      timestamps(type: :timestamptz)
    end

    create index(:trainsformer_services, [:export_id])

    create table(:trainsformer_service_dates) do
      add :start_date, :date
      add :end_date, :date
      add :service_id, references(:trainsformer_services, on_delete: :nothing)
    end

    create index(:trainsformer_service_dates, [:service_id])

    create table(:trainsformer_export_routes) do
      add :route_id, :string
      add :export_id, references(:trainsformer_exports, on_delete: :nothing)
    end

    create index(:trainsformer_export_routes, [:export_id])

    alter table(:trainsformer_exports) do
      add :name, :string
    end

    execute "UPDATE trainsformer_exports SET name = 'export'", ""
  end
end
