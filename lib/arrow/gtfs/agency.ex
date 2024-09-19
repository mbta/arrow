defmodule Arrow.Gtfs.Agency do
  use Arrow.Gtfs.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          url: String.t(),
          timezone: String.t(),
          lang: String.t() | nil,
          phone: String.t() | nil
        }

  schema "gtfs_agencies" do
    field :name, :string
    field :url, :string
    field :timezone, :string
    field :lang, :string
    field :phone, :string

    has_many :routes, Arrow.Gtfs.Route
  end

  def changeset(agency, attrs) do
    attrs = remove_table_prefix(attrs, "agency")

    agency
    |> cast(attrs, ~w[id name url timezone lang phone]a)
    |> validate_required(~w[id name url timezone]a)
  end
end
