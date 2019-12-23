defmodule Arrow.Repo.Migrations.CreateDisruptions do
  use Ecto.Migration

  def change do
    create table(:disruptions) do
      add :start_date, :date
      add :end_date, :date

      timestamps(type: :timestamptz)
    end
  end
end
