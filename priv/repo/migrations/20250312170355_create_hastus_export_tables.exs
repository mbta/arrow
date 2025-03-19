defmodule Arrow.Repo.Migrations.CreateHastusExportTables do
  use Ecto.Migration

  def change do
    create table(:hastus_exports) do
      add :s3_path, :string
      add :line_id, references(:gtfs_lines, type: :varchar, on_delete: :nothing)
      add :disruption_id, references(:disruptionsv2, on_delete: :nothing)

      timestamps(type: :timestamptz)
    end

    create index(:hastus_exports, [:line_id])
    create index(:hastus_exports, [:disruption_id])

    create table(:hastus_services) do
      add :name, :string
      add :export_id, references(:hastus_exports, on_delete: :nothing)

      timestamps(type: :timestamptz)
    end

    create index(:hastus_services, [:export_id])

    create table(:hastus_service_dates) do
      add :start_date, :date
      add :end_date, :date
      add :service_id, references(:hastus_services, on_delete: :nothing)

      timestamps(type: :timestamptz)
    end

    create index(:hastus_service_dates, [:service_id])
  end
end
