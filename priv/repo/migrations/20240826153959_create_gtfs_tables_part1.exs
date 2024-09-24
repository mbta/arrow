defmodule Arrow.Repo.Migrations.CreateGtfsTablesPart1 do
  @moduledoc """
  Creates auxiliary tables referenced by fields in the more frequently-used
  GTFS-static tables.

  Column names omit the `${table_name}_` prefix of their CSV counterparts.
  """

  use Ecto.Migration

  import Arrow.Repo.MigrationHelper,
    only: [create_and_populate_enum_table: 2, create_deferrable: 2]

  def change do
    ###########################################
    # Tables enumerating integer-coded fields #
    ###########################################
    create_and_populate_enum_table("gtfs_service_exception_types", %{
      1 => "Added",
      2 => "Removed"
    })

    create_and_populate_enum_table("gtfs_route_types", [
      "Light Rail",
      "Heavy Rail",
      "Commuter Rail",
      "Bus",
      "Ferry"
    ])

    create_and_populate_enum_table("gtfs_location_types", [
      "Stop/Platform",
      "Parent Station",
      "Entrance/Exit",
      "Generic Node",
      "Boarding Area"
    ])

    create_and_populate_enum_table("gtfs_wheelchair_boarding_types", [
      "No Information / Inherit From Parent",
      "Accessible",
      "Not Accessible"
    ])

    create_and_populate_enum_table("gtfs_bike_boarding_types", [
      "No Information",
      "Bikes Allowed",
      "Bikes Not Allowed"
    ])

    create_and_populate_enum_table("gtfs_route_pattern_typicalities", [
      "Not defined",
      "Typical",
      "Deviation",
      "Atypical",
      "Diversion",
      "Typical But Unscheduled"
    ])

    create_and_populate_enum_table("gtfs_canonicalities", [
      "No Canonical Patterns Defined For Route",
      "Canonical",
      "Not Canonical"
    ])

    create_and_populate_enum_table("gtfs_listed_routes", [
      "Included",
      "Excluded"
    ])

    create_and_populate_enum_table("gtfs_pickup_drop_off_types", [
      "Regularly Scheduled",
      "Not Available",
      "Phone Agency to Arrange",
      "Coordinate With Driver / Commuter Rail Flag Stop"
    ])

    create_and_populate_enum_table("gtfs_timepoint_types", [
      "Approximate",
      "Exact"
    ])

    create_and_populate_enum_table("gtfs_continuous_pickup_drop_off_types", [
      "Continuous",
      "Not Continuous",
      "Phone Agency to Arrange",
      "Coordinate With Driver"
    ])

    #################################
    # Tables with zero dependencies #
    #################################
    create_deferrable table("gtfs_feed_info", primary_key: [name: :id, type: :string]) do
      add :publisher_name, :string, null: false
      add :publisher_url, :string, null: false
      add :lang, :string, null: false
      add :start_date, :date, null: false
      add :end_date, :date, null: false
      add :version, :string, null: false
      add :contact_email, :string, null: false
    end

    create_deferrable table("gtfs_agencies", primary_key: [name: :id, type: :string]) do
      add :name, :string, null: false
      add :url, :string, null: false
      add :timezone, :string, null: false
      add :lang, :string
      add :phone, :string
    end

    create_deferrable table("gtfs_checkpoints", primary_key: [name: :id, type: :string]) do
      add :name, :string, null: false
    end

    create_deferrable table("gtfs_levels", primary_key: [name: :id, type: :string]) do
      add :index, :float, null: false
      add :name, :string
      # `level_elevation` column is included but empty in the CSV and not
      # mentioned in either the official spec or our reference.
      # add :elevation, :string
    end

    create_deferrable table("gtfs_lines", primary_key: [name: :id, type: :string]) do
      # Spec says always included, but column is partially empty
      add :short_name, :string
      add :long_name, :string, null: false
      # Spec says always included, but column is partially empty
      add :desc, :string
      add :url, :string
      add :color, :string, null: false
      add :text_color, :string, null: false
      add :sort_order, :integer, null: false
    end
  end
end
