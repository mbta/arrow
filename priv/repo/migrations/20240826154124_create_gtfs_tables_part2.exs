defmodule Arrow.Repo.Migrations.CreateGtfsTablesPart2 do
  use Ecto.Migration
  import Arrow.Gtfs.MigrationHelper

  def change do
    # A new table that allows us to easily view all
    # calendar/calendar_dates entries referencing a given service_id.
    create table("gtfs_services", primary_key: [name: :id, type: :string])

    create table("gtfs_calendars", primary_key: false) do
      add :service_id, references("gtfs_services", type: :string), primary_key: true

      for day <- ~w[monday tuesday wednesday thursday friday saturday sunday]a do
        add day, :boolean, null: false
      end

      add :start_date, :date, null: false
      add :end_date, :date, null: false
    end

    create table("gtfs_calendar_dates", primary_key: false) do
      add :service_id, references("gtfs_services", type: :string), primary_key: true
      add :date, :date, primary_key: true
      add :exception_type, :integer, null: false
      add :holiday_name, :string
    end

    create_int_code_constraint("gtfs_calendar_dates", :exception_type, 1..2)

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
      add :location_type, :integer, null: false
      add :parent_station_id, references("gtfs_stops", type: :string)
      add :wheelchair_boarding, :integer, null: false
      add :municipality, :string
      add :on_street, :string
      add :at_street, :string
      add :vehicle_type, :integer
    end

    create_int_code_constraint("gtfs_stops", :location_type, 4)
    create_int_code_constraint("gtfs_stops", :wheelchair_boarding, 2)
    create_int_code_constraint("gtfs_stops", :vehicle_type, 4)

    create table("gtfs_shapes", primary_key: [name: :id, type: :string])

    # Individual points are separated into another table to properly
    # form the 1:* relationship and allow FK relations to gtfs_shapes.
    create table("gtfs_shape_points", primary_key: false) do
      add :shape_id, references("gtfs_shapes", type: :string), primary_key: true
      add :lat, :float, null: false
      add :lon, :float, null: false
      add :sequence, :integer, primary_key: true
      # Column is empty, maybe should omit it?
      add :dist_traveled, :float
    end
  end
end
