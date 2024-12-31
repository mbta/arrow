defmodule Arrow.Repo.Migrations.ShuttleStopsUniqueStopId do
  use Ecto.Migration

  def change do
    create unique_index(:stops, [:stop_id])
  end
end
