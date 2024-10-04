defmodule Arrow.Shuttles.Stop do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:stop_name, :stop_desc, :stop_lat, :stop_lon]}

  @type id :: integer
  @type t :: %__MODULE__{
          id: id,
          stop_id: String.t(),
          stop_name: String.t(),
          stop_desc: String.t(),
          platform_code: String.t(),
          platform_name: String.t(),
          stop_lat: float(),
          stop_lon: float(),
          stop_address: String.t(),
          zone_id: String.t(),
          level_id: String.t(),
          parent_station: String.t(),
          municipality: String.t(),
          on_street: String.t(),
          at_street: String.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "stops" do
    field(:stop_id, :string)
    field(:stop_name, :string)
    field(:stop_desc, :string)
    field(:platform_code, :string)
    field(:platform_name, :string)
    field(:stop_lat, :float)
    field(:stop_lon, :float)
    field(:stop_address, :string)
    field(:zone_id, :string)
    field(:level_id, :string)
    field(:parent_station, :string)
    field(:municipality, :string)
    field(:on_street, :string)
    field(:at_street, :string)

    timestamps(type: :utc_datetime)
  end

  @required_fields [:stop_id, :stop_name, :stop_desc, :stop_lat, :stop_lon, :municipality]
  @permitted_fields @required_fields ++
                      [
                        :platform_code,
                        :platform_name,
                        :stop_address,
                        :zone_id,
                        :level_id,
                        :parent_station,
                        :on_street,
                        :at_street
                      ]

  @doc false
  def changeset(stop, attrs) do
    stop
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> unsafe_validate_unique([:stop_id], Arrow.Repo)
    |> unique_constraint(:stop_id)
  end
end
