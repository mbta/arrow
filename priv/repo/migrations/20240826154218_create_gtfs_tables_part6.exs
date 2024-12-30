defmodule Arrow.Repo.Migrations.CreateGtfsTablesPart6 do
  use Ecto.Migration
  import Arrow.Gtfs.MigrationHelper

  def change do
    create table("gtfs_stop_times", primary_key: false) do
      add :trip_id, references("gtfs_trips", type: :string), primary_key: true
      # Arrival and departure times are preserved as their original timestamps
      # to allow for efficient import and to properly represent after-midnight values.
      add :arrival_time, :string, null: false
      add :departure_time, :string, null: false
      add :stop_id, references("gtfs_stops", type: :string), null: false
      add :stop_sequence, :integer, primary_key: true
      add :stop_headsign, :string
      add :pickup_type, :integer, null: false
      add :drop_off_type, :integer, null: false
      add :timepoint, :integer
      add :checkpoint_id, references("gtfs_checkpoints", type: :string)
      add :continuous_pickup, :integer
      add :continuous_drop_off, :integer
    end

    create_int_code_constraint("gtfs_stop_times", :pickup_type, 3)
    create_int_code_constraint("gtfs_stop_times", :drop_off_type, 3)
    create_int_code_constraint("gtfs_stop_times", :timepoint, 1)
    create_int_code_constraint("gtfs_stop_times", :continuous_pickup, 3)
    create_int_code_constraint("gtfs_stop_times", :continuous_drop_off, 3)
  end
end
