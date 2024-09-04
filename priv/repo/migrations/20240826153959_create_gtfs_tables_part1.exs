defmodule Arrow.Repo.Migrations.CreateGtfsTablesPart1 do
  @moduledoc """
  Creates auxiliary tables referenced by fields in the more frequently-used
  GTFS-static tables.

  Column names omit the `${table_name}_` prefix of their CSV counterparts.
  """

  use Ecto.Migration

  def change do
    create table("gtfs_agencies", primary_key: [name: :id, type: :integer]) do
      add :name, :string, null: false
      add :url, :string, null: false
      add :timezone, :string, null: false
      add :lang, :string
      add :phone, :string
    end

    create table("gtfs_checkpoints", primary_key: [name: :id, type: :string]) do
      add :name, :string, null: false
    end

    create table("gtfs_levels", primary_key: [name: :id, type: :string]) do
      add :index, :float, null: false
      add :name, :string
      # `level_elevation` column is included but empty in the CSV and not
      # mentioned in either the official spec or our reference.
      # add :elevation, :string
    end

    create table("gtfs_lines", primary_key: [name: :id, type: :string]) do
      add :short_name, :string, null: false
      add :long_name, :string, null: false
      add :desc, :string, null: false
      add :url, :string
      # Maybe integer
      add :color, :string, null: false
      # Maybe integer
      add :text_color, :string, null: false
      add :sort_order, :integer, null: false
    end
  end
end
