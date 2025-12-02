defmodule Arrow.Repo.Migrations.CreateTrainsformerExportsTables do
  use Ecto.Migration

  def change do
    create table(:trainsformer_exports) do
      add :s3_path, :string
      add :disruption_id, references(:disruptionsv2, on_delete: :nothing)

      timestamps(type: :timestamptz)
    end

    create index(:trainsformer_exports, [:disruption_id])
  end
end
