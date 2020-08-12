defmodule Arrow.Disruption.TripShortName do
  use Ecto.Schema
  import Ecto.Changeset

  alias Arrow.Disruption

  @type t :: %__MODULE__{
          trip_short_name: String.t() | nil,
          disruption_revision: Disruption.Revision | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t()
        }

  schema "disruption_trip_short_names" do
    field :trip_short_name, :string
    belongs_to :disruption_revision, Disruption.Revision

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(trip_short_name, attrs) do
    trip_short_name
    |> cast(attrs, [:id, :trip_short_name])
    |> validate_required([:trip_short_name])
  end
end
