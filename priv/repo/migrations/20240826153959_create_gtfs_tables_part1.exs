defmodule Arrow.Repo.Migrations.CreateGtfsTablesPart1 do
  @moduledoc """
  Creates auxiliary tables referenced by fields in the more frequently-used
  GTFS-static tables.

  Column names omit the `${table_name}_` prefix of their CSV counterparts.
  """
  use Ecto.Migration

  def change do
    #################################
    # Tables with zero dependencies #
    #################################
    create table("gtfs_feed_info", primary_key: [name: :id, type: :string]) do
      add :publisher_name, :string, null: false
      add :publisher_url, :string, null: false
      add :lang, :string, null: false
      add :start_date, :date, null: false
      add :end_date, :date, null: false
      add :version, :string, null: false
      add :contact_email, :string, null: false
    end

    create table("gtfs_agencies", primary_key: [name: :id, type: :string]) do
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
