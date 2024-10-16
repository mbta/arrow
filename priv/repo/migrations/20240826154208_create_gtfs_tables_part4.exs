defmodule Arrow.Repo.Migrations.CreateGtfsTablesPart4 do
  use Ecto.Migration
  import Arrow.Gtfs.MigrationHelper

  def change do
    create_enum_type("direction_desc", [
      "North",
      "South",
      "East",
      "West",
      "Northeast",
      "Northwest",
      "Southeast",
      "Southwest",
      "Clockwise",
      "Counterclockwise",
      "Inbound",
      "Outbound",
      "Loop A",
      "Loop B",
      "Loop"
    ])

    create table("gtfs_directions", primary_key: false) do
      add :route_id, references("gtfs_routes", type: :string), primary_key: true
      add :direction_id, :integer, primary_key: true
      add :desc, :direction_desc, null: false
      add :destination, :string, null: false
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
      add :typicality, :integer, null: false
      add :sort_order, :integer, null: false
      # References gtfs_trips, but we haven't created that yet. (gtfs_trips
      # references this table, so we'll need to add a deferred FK constraint to
      # this column later.)
      add :representative_trip_id, :string, null: false

      # Make an integer-code table for this?
      add :canonical, :integer, null: false
    end

    create_int_code_constraint("gtfs_route_patterns", :typicality, 5)
    create_int_code_constraint("gtfs_route_patterns", :canonical, 2)
  end
end
