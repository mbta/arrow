defmodule Arrow.Repo.Migrations.AddCoordinatesToShapes do
  use Ecto.Migration

  def change do
    alter table(:shapes) do
      add :coordinates, {:array, :string}
    end
  end

  def down do
    alter table(:shapes) do
      remove :coordinates
    end
  end
end
