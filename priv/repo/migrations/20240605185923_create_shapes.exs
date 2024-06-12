defmodule Arrow.Repo.Migrations.CreateShapes do
  use Ecto.Migration

  def change do
    create table(:shapes) do
      add :name, :string

      timestamps(type: :timestamptz)
    end

    create unique_index(:shapes, [:name])
  end
end
