defmodule Arrow.Gtfs.Line do
  use Arrow.Gtfs.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: String.t(),
          short_name: String.t(),
          long_name: String.t(),
          desc: String.t(),
          url: String.t() | nil,
          color: String.t(),
          text_color: String.t(),
          sort_order: integer
        }

  schema "gtfs_lines" do
    field :short_name, :string
    field :long_name, :string
    field :desc, :string
    field :url, :string
    field :color, :string
    field :text_color, :string
    field :sort_order, :integer
  end

  def changeset(line, attrs) do
    attrs = remove_table_prefix(attrs, "line")

    line
    |> cast(attrs, ~w[id short_name long_name desc url color text_color sort_order]a)
    |> validate_required(~w[id long_name color text_color sort_order]a)
  end
end
