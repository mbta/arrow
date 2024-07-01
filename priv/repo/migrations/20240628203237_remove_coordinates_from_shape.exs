defmodule Arrow.Repo.Migrations.RemoveCoordinatesFromShape do
  use Ecto.Migration

  def change do
    alter table(:shapes) do
      remove :coordinates
    end
  end

  def down do
    alter table(:shapes) do
      add :coordinates, {:array, :string}
    end
  end
end
