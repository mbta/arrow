defmodule Arrow.Repo.Migrations.RemoveHastusServiceStartEndStopColumns do
  use Ecto.Migration

  def change do
    alter table(:hastus_services) do
      remove :start_stop_id, references(:gtfs_stops, type: :string, on_delete: :nilify_all)
      remove :end_stop_id, references(:gtfs_stops, type: :string, on_delete: :nilify_all)
    end
  end
end
