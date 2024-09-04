defmodule Arrow.Repo.Migrations.CreateGtfsTablesPart2 do
  use Ecto.Migration

  def change do
    create table("gtfs_route_types", primary_key: [name: :id, type: :integer]) do
      add :name, :string, null: false
    end

    execute(&route_types_up/0, &route_types_down/0)

    create table("gtfs_calendar", primary_key: [name: :service_id, type: :string]) do
      for day <- ~w[monday tuesday wednesday thursday friday saturday sunday]a do
        add day, :boolean, null: false
      end

      add :start_date, :integer, null: false
      add :end_date, :integer, null: false
    end

    create table("gtfs_calendar_dates", primary_key: false) do
      add :service_id, references("gtfs_calendar", column: :service_id, type: :string),
        primary_key: true

      # Dates are formatted like YearMonthDay, e.g. 20240829
      add :date, :integer, primary_key: true
      add :exception_type, :integer, null: false
      add :holiday_name, :string
    end

    create table("gtfs_stops", primary_key: [name: :id, type: :string]) do
      add :code, :string
      add :name, :string, null: false
      add :desc, :string
      add :platform_code, :string
      add :platform_name, :string
      add :lat, :float
      add :lon, :float
      add :zone_id, :string
      add :address, :string
      add :url, :string
      add :level_id, references("gtfs_levels", type: :string)
      # Really an enum type like route_type
      add :location_type, :integer, null: false
      add :parent_station, references("gtfs_stops", type: :string)
      add :wheelchair_boarding, :integer, null: false
      add :municipality, :string
      add :on_street, :string
      add :at_street, :string
      add :vehicle_type, references("gtfs_route_types", type: :integer)
    end

    create table("gtfs_shapes", primary_key: [name: :id, type: :integer])

    # Individual points are separated into another table to properly
    # form the 1:* relationship and allow FK relations to gtfs_shapes.
    create table("gtfs_shape_points", primary_key: false) do
      add :shaped_id, references("gtfs_shapes", type: :integer), primary_key: true
      add :sequence, :integer, primary_key: true
      add :lat, :float, null: false
      add :lon, :float, null: false
      # Column is empty, maybe should omit it?
      add :dist_traveled, :float
    end
  end

  # 1. Does this seem useful to define at the DB level
  # 2. If yes, should I do this for other enum-ish columns like stops.location_type
  defp route_types_up do
    repo().query!("""
    INSERT INTO "gtfs_route_types" ("id", "name") VALUES
        (0, 'Light Rail'),
        (1, 'Heavy Rail'),
        (2, 'Commuter Rail'),
        (3, 'Bus'),
        (4, 'Ferry')
    """)
  end

  defp route_types_down, do: nil
end
