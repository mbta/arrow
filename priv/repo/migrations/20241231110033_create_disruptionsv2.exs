defmodule Arrow.Repo.Migrations.CreateDisruptionsv2 do
  use Ecto.Migration

  def change do
    create table(:disruptionsv2) do
      add :title, :string
      add :mode, :string
      add :is_active, :boolean
      add :description, :text

      timestamps()
    end
  end
end
