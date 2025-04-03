defmodule Arrow.Repo.Migrations.AddStartAndEndStopIdsToHastusServices do
  use Ecto.Migration

  def change do
    alter table(:hastus_services) do
      add :start_stop_id, references(:gtfs_stops, type: :string, on_delete: :nilify_all)
      add :end_stop_id, references(:gtfs_stops, type: :string, on_delete: :nilify_all)
    end
  end
end
