defmodule Arrow.ShuttleStop do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Query

  @type id :: integer
  @type t :: %__MODULE__{
          id: id,
          stop_id: String.t(),
          stop_name: String.t(),
          stop_desc: String.t(),
          platform_code: String.t(),
          platform_name: String.t(),
          stop_lat: String.t(),
          stop_long: String.t(),
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

  schema "shuttle_stops" do
    field(:stop_id, :string)
    field(:stop_name, :string)
    field(:stop_desc, :string)
    field(:platform_code, :string)
    field(:platform_name, :string)
    field(:stop_lat, :string)
    field(:stop_long, :string)
    field(:stop_address, :string)
    field(:zone_id, :string)
    field(:level_id, :string)
    field(:parent_station, :string)
    field(:municipality, :string)
    field(:on_street, :string)
    field(:at_street, :string)

    timestamps(type: :utc_datetime)
  end

  @required_fields [:stop_id, :stop_name, :stop_desc, :stop_lat, :stop_long, :municipality]
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
end
