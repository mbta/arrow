defmodule Arrow.Repo.Migrations.CreateAdjustments do
  use Ecto.Migration

  def change do
    create table(:adjustments) do
      add :source, :string
      add :source_label, :string
      add :route_id, :string

      timestamps(type: :timestamptz)
    end

    create unique_index(:adjustments, [:source, :source_label],
             name: :adjustments_source_source_label
           )
  end
end
