defmodule Arrow.Disruption.TripShortName do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          trip_short_name: String.t() | nil,
          disruption: Arrow.Disruption | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  schema "disruption_trip_short_names" do
    field :trip_short_name, :string
    belongs_to :disruption, Arrow.Disruption

    timestamps(type: :utc_datetime)
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(trip_short_name, attrs) do
    trip_short_name
    |> cast(attrs, [:id, :trip_short_name])
    |> validate_required([:trip_short_name])
  end
end
