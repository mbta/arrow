defmodule Arrow.Repo.Migrations.MoveShuttleSuffixColumn do
  use Ecto.Migration

  def change do
    alter table(:shuttles) do
      add :suffix, :string
    end

    alter table(:shuttle_routes) do
      remove :suffix, :string
    end
  end
end
