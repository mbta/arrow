defmodule Arrow.Repo.Migrations.CreateGtfsTablesPart6 do
  use Ecto.Migration

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
      add :pickup_type, references("gtfs_pickup_drop_off_types", type: :integer), null: false
      add :drop_off_type, references("gtfs_pickup_drop_off_types", type: :integer), null: false
      add :timepoint, references("gtfs_timepoint_types", type: :integer)
      add :checkpoint_id, references("gtfs_checkpoints", type: :string)
      add :continuous_pickup, references("gtfs_continuous_pickup_drop_off_types", type: :integer)

      add :continuous_drop_off,
          references("gtfs_continuous_pickup_drop_off_types", type: :integer)
    end
  end
end