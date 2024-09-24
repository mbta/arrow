defmodule Arrow.Repo.Migrations.CreateGtfsTablesPart4 do
  use Ecto.Migration

  import Arrow.Repo.MigrationHelper, only: [create_deferrable: 2]

  def change do
    create_deferrable table("gtfs_directions", primary_key: false) do
      add :route_id, references("gtfs_routes", type: :string), primary_key: true
      add :direction_id, :integer, primary_key: true
      # Make an enum type for this?
      add :desc, :string, null: false
      add :destination, :string, null: false
    end

    create_deferrable table("gtfs_route_patterns", primary_key: [name: :id, type: :string]) do
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
      add :typicality, references("gtfs_route_pattern_typicalities", type: :integer), null: false
      add :sort_order, :integer, null: false
      # References gtfs_trips, but we haven't created that yet. (gtfs_trips
      # references this table, so we'll need to add a DEFERRED FK constraint to
      # this column later.)
      add :representative_trip_id, :string, null: false

      # Make an integer-code table for this?
      add :canonical, references("gtfs_canonicalities", type: :integer), null: false
    end
  end
end
