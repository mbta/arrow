defmodule Arrow.Gtfs.Route do
  @moduledoc """
  Represents a row from routes.txt.

  Changeset is intended for use only in CSV imports--
  table contents should be considered read-only otherwise.
  """
  use Arrow.Gtfs.Schema

  import Ecto.Changeset

  alias Arrow.Gtfs.Agency
  alias Arrow.Gtfs.Line
  alias Arrow.Gtfs.RoutePattern
  alias Ecto.Association.NotLoaded

  @type t :: %__MODULE__{
          id: String.t(),
          agency: Agency.t() | NotLoaded.t(),
          short_name: String.t() | nil,
          long_name: String.t() | nil,
          desc: String.t(),
          type: atom,
          url: String.t() | nil,
          color: String.t() | nil,
          text_color: String.t() | nil,
          sort_order: integer,
          fare_class: String.t(),
          line: Line.t() | NotLoaded.t(),
          listed_route: atom,
          network_id: String.t(),
          route_patterns: list(RoutePattern.t()) | NotLoaded.t()
        }

  @route_type_values Enum.with_index(~w[light_rail heavy_rail commuter_rail bus ferry]a)

  schema "gtfs_routes" do
    belongs_to :agency, Agency
    field :short_name, :string
    field :long_name, :string
    field :desc, :string

    field :type, Ecto.Enum, values: @route_type_values

    field :url, :string
    field :color, :string
    field :text_color, :string
    field :sort_order, :integer
    field :fare_class, :string
    belongs_to :line, Line
    field :listed_route, Ecto.Enum, values: Enum.with_index(~w[Included Excluded]a)
    field :network_id, :string

    has_many :directions, Arrow.Gtfs.Direction
    has_many :trips, Arrow.Gtfs.Trip
    has_many :route_patterns, RoutePattern
  end

  def changeset(route, attrs) do
    attrs =
      attrs
      |> remove_table_prefix("route")
      |> values_to_int(~w[type listed_route])

    route
    |> cast(
      attrs,
      ~w[id agency_id short_name long_name desc type url color text_color sort_order fare_class line_id listed_route network_id]a
    )
    |> validate_required(~w[id agency_id desc type sort_order fare_class network_id]a)
    |> assoc_constraint(:agency)
    |> assoc_constraint(:line)
  end

  @impl Arrow.Gtfs.Importable
  def filenames, do: ["routes.txt"]
end
