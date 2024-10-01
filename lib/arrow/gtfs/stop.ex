defmodule Arrow.Gtfs.Stop do
  @moduledoc """
  Represents a row from stops.txt.

  Changeset is intended for use only in CSV imports--
  table contents should be considered read-only otherwise.
  """
  use Arrow.Gtfs.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: String.t(),
          code: String.t() | nil,
          name: String.t(),
          desc: String.t() | nil,
          platform_code: String.t() | nil,
          platform_name: String.t() | nil,
          lat: float,
          lon: float,
          zone_id: String.t() | nil,
          address: String.t() | nil,
          url: String.t() | nil,
          level: Arrow.Gtfs.Level.t() | Ecto.Association.NotLoaded.t() | nil,
          location_type: atom,
          parent_station: t() | Ecto.Association.NotLoaded.t() | nil,
          wheelchair_boarding: atom,
          municipality: String.t() | nil,
          on_street: String.t() | nil,
          at_street: String.t() | nil,
          vehicle_type: atom,
          times: list(Arrow.Gtfs.StopTime.t()) | Ecto.Association.NotLoaded.t()
        }

  schema "gtfs_stops" do
    field :code, :string
    field :name, :string
    field :desc, :string
    field :platform_code, :string
    field :platform_name, :string
    field :lat, :float
    field :lon, :float
    field :zone_id, :string
    field :address, :string
    field :url, :string
    belongs_to :level, Arrow.Gtfs.Level

    field :location_type, Arrow.Gtfs.Types.Enum,
      values:
        Enum.with_index(
          ~w[stop_platform parent_station entrance_exit generic_node boarding_area]a
        )

    belongs_to :parent_station, Arrow.Gtfs.Stop

    field :wheelchair_boarding,
          Arrow.Gtfs.Types.Enum,
          values: Enum.with_index(~w[no_info_inherit_from_parent accessible not_accessible]a)

    field :municipality, :string
    field :on_street, :string
    field :at_street, :string

    field :vehicle_type, Arrow.Gtfs.Types.Enum,
      values: Enum.with_index(~w[light_rail heavy_rail commuter_rail bus ferry]a)

    has_many :times, Arrow.Gtfs.StopTime
  end

  def changeset(stop, attrs) do
    attrs =
      attrs
      |> remove_table_prefix("stop")
      # `parent_station` is inconsistently named--this changes the key to
      # `parent_station_id` if it's set. (Which it should be!)
      |> Map.pop("parent_station")
      |> then(fn
        {nil, attrs} -> attrs
        {parent_station_id, attrs} -> Map.put(attrs, "parent_station_id", parent_station_id)
      end)

    stop
    |> cast(
      attrs,
      ~w[id code name desc platform_code platform_name lat lon zone_id address url level_id location_type parent_station_id wheelchair_boarding municipality on_street at_street vehicle_type]a
    )
    |> validate_required(~w[id name location_type wheelchair_boarding]a)
    |> assoc_constraint(:level)
    |> assoc_constraint(:parent_station)
  end

  @impl Arrow.Gtfs.Importable
  def filenames, do: ["stops.txt"]
end
