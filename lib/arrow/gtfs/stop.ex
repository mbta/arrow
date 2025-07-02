defmodule Arrow.Gtfs.Stop do
  @moduledoc """
  Represents a row from stops.txt.

  Changeset is intended for use only in CSV imports--
  table contents should be considered read-only otherwise.
  """
  use Arrow.Gtfs.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Arrow.Gtfs.Level
  alias Arrow.Gtfs.Stop
  alias Arrow.Gtfs.StopTime
  alias Arrow.Repo
  alias Ecto.Association.NotLoaded

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
          level: Level.t() | NotLoaded.t() | nil,
          location_type: atom,
          parent_station: t() | NotLoaded.t() | nil,
          wheelchair_boarding: atom,
          municipality: String.t() | nil,
          on_street: String.t() | nil,
          at_street: String.t() | nil,
          vehicle_type: atom,
          times: list(StopTime.t()) | NotLoaded.t()
        }

  @location_type_values Enum.with_index(~w[stop_platform parent_station entrance_exit generic_node boarding_area]a)

  @wheelchair_boarding_values Enum.with_index(~w[no_info_inherit_from_parent accessible not_accessible]a)

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
    belongs_to :level, Level
    field :location_type, Ecto.Enum, values: @location_type_values
    belongs_to :parent_station, Stop
    field :wheelchair_boarding, Ecto.Enum, values: @wheelchair_boarding_values
    field :municipality, :string
    field :on_street, :string
    field :at_street, :string
    field :vehicle_type, Ecto.Enum, values: @vehicle_type_values
    has_many :times, StopTime
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

  @doc """
  Get GTFS stops within one mile of a given longitude and latitude, excluding 
  the stops that duplicate an arrow stop identified by `arrow_stop_id` 

  ## Examples
      iex> Arrow.Gtfs.Stop.get_stops_within_mile("123", {42.3774, -72.1189})
      [%Arrow.Gtfs.Stop, ...]

      iex> Arrow.Gtfs.Stop.get_stops_within_mile(nil, {42.3774, -72.1189})
      [%Arrow.Gtfs.Stop, ...]
  """
  @spec get_stops_within_mile(String.t() | nil, {float(), float()}) :: list(Stop.t())
  def get_stops_within_mile(arrow_stop_id, {lat, lon}) do
    conditions =
      dynamic(
        [s],
        s.lat <= ^lat + @latitude_degrees_per_mile and
          s.lat >= ^lat - @latitude_degrees_per_mile and
          s.lon <= ^lon + @longitude_degrees_per_mile and
          s.lon >= ^lon - @latitude_degrees_per_mile and
          s.vehicle_type == :bus
      )

    conditions =
      if is_nil(arrow_stop_id) do
        conditions
      else
        dynamic([s], s.id != ^arrow_stop_id and ^conditions)
      end

    query =
      from(s in Stop,
        where: ^conditions
      )

    Repo.all(query)
  end

  @impl Arrow.Gtfs.Importable
  def filenames, do: ["stops.txt"]
end
