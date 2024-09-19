defmodule Arrow.Repo.Migrations.CreateGtfsTablesPart3 do
  use Ecto.Migration

  def change do
    create table("gtfs_routes", primary_key: [name: :id, type: :string]) do
      add :agency_id, references("gtfs_agencies", type: :string), null: false
      add :short_name, :string
      add :long_name, :string
      # One of a finite list of strings - make an enum?
      add :desc, :string, null: false
      add :type, references("gtfs_route_types", type: :integer), null: false
      add :url, :string
      add :color, :string
      add :text_color, :string
      add :sort_order, :integer, null: false
      # TODO: Create atom->string Ecto.Enum and Postgres string enum types for this
      add :fare_class, :string, null: false
      add :line_id, references("gtfs_lines", type: :string)
      add :listed_route, references("gtfs_listed_routes", type: :integer)
      # TODO: Create atom->string Ecto.Enum and Postgres string enum types for this
      add :network_id, :string, null: false
    end
  end
end
