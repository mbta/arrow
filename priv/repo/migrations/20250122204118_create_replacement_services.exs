defmodule Arrow.Repo.Migrations.CreateReplacementServices do
  use Ecto.Migration

  def change do
    create table(:replacement_services) do
      add :reason, :string
      add :start_date, :date
      add :end_date, :date
      add :source_workbook_data, :map
      add :source_workbook_filename, :string
      add :disruption_id, references(:disruptionsv2, on_delete: :nothing)
      add :shuttle_id, references(:shuttles, on_delete: :nothing)

      timestamps(type: :timestamptz)
    end

    create index(:replacement_services, [:disruption_id])
    create index(:replacement_services, [:shuttle_id])
  end
end
