defmodule Arrow.Repo.Migrations.CreateGtfsTablesPart2 do
  use Ecto.Migration

  def change do
    create table("gtfs_services", primary_key: [name: :id, type: :string]) do
      for day <- ~w[monday tuesday wednesday thursday friday saturday sunday]a do
        add day, :boolean, null: false
      end

      add :start_date, :date, null: false
      add :end_date, :date, null: false
    end

    create table("gtfs_service_dates", primary_key: false) do
      add :service_id, references("gtfs_services", type: :string), primary_key: true
      add :date, :date, primary_key: true
      add :exception_type, references("gtfs_service_exception_types", type: :integer), null: false
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
      add :location_type, references("gtfs_location_types", type: :integer), null: false
      add :parent_station_id, references("gtfs_stops", type: :string)

      add :wheelchair_boarding, references("gtfs_wheelchair_boarding_types", type: :integer),
        null: false

      add :municipality, :string
      add :on_street, :string
      add :at_street, :string
      add :vehicle_type, references("gtfs_route_types", type: :integer)
    end

    create table("gtfs_shapes", primary_key: [name: :id, type: :string])

    # Individual points are separated into another table to properly
    # form the 1:* relationship and allow FK relations to gtfs_shapes.
    create table("gtfs_shape_points", primary_key: false) do
      add :shape_id, references("gtfs_shapes", type: :string), primary_key: true
      add :sequence, :integer, primary_key: true
      add :lat, :float, null: false
      add :lon, :float, null: false
      # Column is empty, maybe should omit it?
      add :dist_traveled, :float
    end
  end
end
