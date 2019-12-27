defmodule Arrow.Disruption.TripShortName do
  use Ecto.Schema
  import Ecto.Changeset

  schema "disruption_trip_short_names" do
    field :trip_short_name, :string
    belongs_to :disruption, Arrow.Disruption

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(trip_short_name, attrs) do
    trip_short_name
    |> cast(attrs, [:trip_short_name])
    |> validate_required([:trip_short_name])
  end
end
