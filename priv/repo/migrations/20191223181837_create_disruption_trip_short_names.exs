defmodule Arrow.Repo.Migrations.CreateDisruptionTripShortNames do
  use Ecto.Migration

  def change do
    create table(:disruption_trip_short_names) do
      add :trip_short_name, :string, null: false
      add :disruption_id, references(:disruptions, on_delete: :delete_all)

      timestamps(type: :timestamptz)
    end

    create index(:disruption_trip_short_names, [:disruption_id])
  end
end
