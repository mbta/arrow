defmodule Arrow.Repo.Migrations.CreateGtfsTablesPart3 do
  use Ecto.Migration
  import Arrow.Gtfs.MigrationHelper

  def change do
    create_enum_type("route_desc", [
      "Commuter Rail",
      "Rapid Transit",
      "Local Bus",
      "Key Bus",
      "Supplemental Bus",
      "Community Bus",
      "Commuter Bus",
      "Ferry",
      "Rail Replacement Bus"
    ])

    create_enum_type("fare_class", [
      "Local Bus",
      "Inner Express",
      "Outer Express",
      "Rapid Transit",
      "Commuter Rail",
      "Ferry",
      "Free",
      "Special"
    ])

    create table("gtfs_routes", primary_key: [name: :id, type: :string]) do
      add :agency_id, references("gtfs_agencies", type: :string), null: false
      add :short_name, :string
      add :long_name, :string
      add :desc, :route_desc, null: false
      add :type, :integer, null: false
      add :url, :string
      add :color, :string
      add :text_color, :string
      add :sort_order, :integer, null: false
      add :fare_class, :fare_class, null: false
      add :line_id, references("gtfs_lines", type: :string)
      add :listed_route, :integer
      add :network_id, :string, null: false
    end

    create_int_code_constraint("gtfs_routes", :type, 4)
    create_int_code_constraint("gtfs_routes", :listed_route, 1)
  end
end
