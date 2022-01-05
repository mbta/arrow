defmodule Arrow.Repo.Migrations.Notes do
  use Ecto.Migration

  def change do
    create table("disruption_notes") do
      add :body, :text, null: false
      add :author, :string, null: false
      add :disruption_id, references(:disruptions, on_delete: :delete_all), null: false

      timestamps(type: :timestamptz)
    end

    create index("disruption_notes", [:disruption_id])
  end
end
