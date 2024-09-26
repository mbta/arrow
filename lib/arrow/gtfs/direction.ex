defmodule Arrow.Gtfs.Direction do
  @moduledoc """
  Represents a row from directions.txt.

  Changeset is intended for use only in CSV imports--
  table contents should be considered read-only otherwise.
  """
  use Arrow.Gtfs.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          route: Arrow.Gtfs.Route.t() | Ecto.Association.NotLoaded.t(),
          direction_id: 0 | 1,
          desc: String.t(),
          destination: String.t()
        }

  @primary_key false

  schema "gtfs_directions" do
    belongs_to :route, Arrow.Gtfs.Route, primary_key: true
    field :direction_id, :integer, primary_key: true
    field :desc, :string
    field :destination, :string
  end

  def changeset(direction, attrs) do
    attrs =
      attrs
      # Taking liberties:
      # `direction` is inconsistently named--the human-readable name is
      # "#{table}_desc" in all other tables.
      |> Map.pop("direction")
      |> then(fn
        {nil, attrs} -> attrs
        {desc, attrs} -> Map.put(attrs, "desc", desc)
      end)
      |> remove_table_prefix("direction", except: ["direction_id"])

    direction
    |> cast(attrs, ~w[route_id direction_id desc destination]a)
    |> validate_required(~w[route_id direction_id desc destination]a)
    |> validate_inclusion(:direction_id, 0..1)
    |> assoc_constraint(:route)
  end

  @impl Arrow.Gtfs.Importable
  def filename, do: "directions.txt"
end
