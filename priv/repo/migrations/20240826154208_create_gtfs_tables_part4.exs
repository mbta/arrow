defmodule Arrow.Repo.Migrations.CreateGtfsTablesPart4 do
  use Ecto.Migration

  def change do
    create table("gtfs_directions", primary_key: false) do
      add :route_id, references("gtfs_routes", type: :string), primary_key: true
      add :direction_id, :integer, primary_key: true
      # Make an enum type for this?
      add :direction, :string, null: false
      add :direction_destination, :string, null: false
    end

    create table("gtfs_route_patterns", primary_key: [name: :id, type: :string]) do
      add :route_id, references("gtfs_routes", type: :string), null: false

      add :direction_id,
          references("gtfs_directions",
            column: :direction_id,
            type: :integer,
            with: [route_id: :route_id]
          ),
          null: false

      add :name, :string, null: false
      add :time_desc, :string
      # May want to define an enum for this
      add :typicality, :integer, null: false
      add :sort_order, :integer, null: false
      # References gtfs_trips, but we haven't created that yet. (gtfs_trips
      # references this table, so we'll need to add a DEFERRED FK constraint to
      # this column later.)
      add :representative_trip_id, :string, null: false

      # Make an enum type for this?
      add :canonical, :integer, null: false
    end
  end
end
