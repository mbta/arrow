defmodule Arrow.Gtfs.Stop do
  @moduledoc """
  Represents a row from stops.txt.

  Changeset is intended for use only in CSV imports--
  table contents should be considered read-only otherwise.
  """
  use Arrow.Gtfs.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Arrow.Repo

  @derive {Jason.Encoder, only: [:name, :desc, :lat, :lon, :id]}

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

  @location_type_values Enum.with_index(
                          ~w[stop_platform parent_station entrance_exit generic_node boarding_area]a
                        )

  @wheelchair_boarding_values Enum.with_index(
                                ~w[no_info_inherit_from_parent accessible not_accessible]a
                              )

  @vehicle_type_values Enum.with_index(~w[light_rail heavy_rail commuter_rail bus ferry]a)

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
    field :location_type, Ecto.Enum, values: @location_type_values
    belongs_to :parent_station, Arrow.Gtfs.Stop
    field :wheelchair_boarding, Ecto.Enum, values: @wheelchair_boarding_values
    field :municipality, :string
    field :on_street, :string
    field :at_street, :string
    field :vehicle_type, Ecto.Enum, values: @vehicle_type_values
    has_many :times, Arrow.Gtfs.StopTime
  end

  def changeset(stop, attrs) do
    attrs =
      attrs
      |> remove_table_prefix("stop")
      # `parent_station` is inconsistently named--this changes the key to `parent_station_id`.
      |> rename_key("parent_station", "parent_station_id")
      |> values_to_int(~w[location_type wheelchair_boarding vehicle_type])

    stop
    |> cast(
      attrs,
      ~w[id code name desc platform_code platform_name lat lon zone_id address url level_id location_type parent_station_id wheelchair_boarding municipality on_street at_street vehicle_type]a
    )
    |> validate_required(~w[id name location_type wheelchair_boarding]a)
    |> assoc_constraint(:level)
    |> assoc_constraint(:parent_station)
  end

  @longitude_degrees_per_mile 1 / 54.6
  @latitude_degrees_per_mile 1 / 69
  def get_stops_within_mile(nil, {lat, lon}) do
    from(s in Arrow.Gtfs.Stop,
      where:
        s.lat <= ^lat + @latitude_degrees_per_mile and
        s.lat >= ^lat - @latitude_degrees_per_mile and
        s.lon <= ^lon + @longitude_degrees_per_mile and
        s.lon >= ^lon - @latitude_degrees_per_mile and
        s.vehicle_type == :bus  
    )
    |> Repo.all()
  end

  @doc """
  Get GTFS stops within one mile of a given longitude and latitude, excluding 
  the stops that duplicate an arrow stop identified by `arrow_stop_id` 

  ## Examples
      iex> Arrow.Gtfs.Stop.get_stops_within_mile("123", {42.3774, -72.1189})
      [%Arrow.Gtfs.Stop, ...]

      iex> Arrow.Gtfs.Stop.get_stops_within_mile(nil, {42.3774, -72.1189})
      [%Arrow.Gtfs.Stop, ...]
  """
  @spec get_stops_within_mile(String.t() | nil, {float(), float()}) :: list(Arrow.Gtfs.Stop.t())
  def get_stops_within_mile(arrow_stop_id, {lat, lon}) do
    from(s in Arrow.Gtfs.Stop,
      where:
        s.id != ^arrow_stop_id and
          s.lat <= ^lat + @latitude_degrees_per_mile and
          s.lat >= ^lat - @latitude_degrees_per_mile and
          s.lon <= ^lon + @longitude_degrees_per_mile and
          s.lon >= ^lon - @latitude_degrees_per_mile
    )
    |> Repo.all()
  end

  @impl Arrow.Gtfs.Importable
  def filenames, do: ["stops.txt"]
end
