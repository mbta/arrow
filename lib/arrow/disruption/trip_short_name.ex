defmodule Arrow.Disruption.TripShortName do
  @moduledoc """
  The `trip_short_name` of the a specific trip a disruption applies to. Normally used to refer to
  Commuter Rail train numbers.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{
          trip_short_name: String.t() | nil,
          disruption_revision: Arrow.DisruptionRevision | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  schema "disruption_trip_short_names" do
    field(:trip_short_name, :string)
    belongs_to(:disruption_revision, Arrow.DisruptionRevision)

    timestamps(type: :utc_datetime)
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(trip_short_name, attrs) do
    trip_short_name
    |> cast(attrs, [:trip_short_name])
    |> validate_required([:trip_short_name])
  end
end
