defmodule Arrow.Repo.Migrations.CreateGtfsTablesPart6 do
  use Ecto.Migration

  def change do
    create table("gtfs_stop_times", primary_key: false) do
      add :trip_id, references("gtfs_trips", type: :string), primary_key: true
      add :stop_sequence, :integer, primary_key: true
      # Maybe type can be :time?
      add :arrival_time, :string, null: false
      add :departure_time, :string, null: false
      add :stop_id, references("gtfs_stops", type: :string), null: false
      add :stop_headsign, :string
      # pickup_type and drop_off_type are enum-ish
      add :pickup_type, :integer, null: false
      add :drop_off_type, :integer, null: false
      # enum-ish
      add :timepoint, :integer
      add :checkpoint_id, references("gtfs_checkpoints", type: :string)
      # continuous_pickup and continuous_drop_off are enum-ish
      add :continuous_pickup, :integer
      add :continuous_drop_off, :integer
    end
  end
end
