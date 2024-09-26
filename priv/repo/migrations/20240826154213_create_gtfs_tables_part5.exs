defmodule Arrow.Repo.Migrations.CreateGtfsTablesPart5 do
  use Ecto.Migration

  def change do
    create table("gtfs_trips", primary_key: [name: :id, type: :string]) do
      add :route_id, references("gtfs_routes", type: :string), null: false
      add :service_id, references("gtfs_services", type: :string), null: false
      add :headsign, :string, null: false
      add :short_name, :string

      add :direction_id,
          references("gtfs_directions",
            column: :direction_id,
            type: :integer,
            with: [route_id: :route_id]
          ),
          null: false

      add :block_id, :string
      add :shape_id, references("gtfs_shapes", type: :string)

      add :wheelchair_accessible, references("gtfs_wheelchair_boarding_types", type: :integer),
        null: false

      add :route_type, references("gtfs_route_types", type: :integer)
      add :route_pattern_id, references("gtfs_route_patterns", type: :string), null: false
      add :bikes_allowed, references("gtfs_bike_boarding_types", type: :integer), null: false
    end

    execute(&route_patterns_deferred_pk_up/0, &route_patterns_deferred_pk_down/0)
  end

  defp route_patterns_deferred_pk_up do
    repo().query!("""
    ALTER TABLE "gtfs_route_patterns"
    ADD CONSTRAINT "gtfs_route_patterns_representative_trip_id_fkey"
      FOREIGN KEY ("representative_trip_id") REFERENCES "gtfs_trips"("id")
      DEFERRABLE INITIALLY DEFERRED
    """)
  end

  defp route_patterns_deferred_pk_down do
    repo().query!("""
    ALTER TABLE "gtfs_route_patterns"
    DROP CONSTRAINT "gtfs_route_patterns_representative_trip_id_fkey"
    """)
  end
end
