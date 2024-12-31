defmodule Arrow.Repo.Migrations.CreateDisruptionsv2 do
  use Ecto.Migration

  def change do
    create table(:disruptionsv2) do
      add :name, :string

      timestamps()
    end
  end
end
