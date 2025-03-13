defmodule Arrow.Repo.Migrations.AddStopTimesIndex do
  use Ecto.Migration

  def change do
    create index(:gtfs_stop_times, [:stop_id])
  end
end
