defmodule Arrow.Disruption.Exception do
  @moduledoc """
  Dates within a disruption's time frame for which it does not apply.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          excluded_date: Date.t() | nil,
          disruption_revision: Arrow.DisruptionRevision | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  schema "disruption_exceptions" do
    field(:excluded_date, :date)
    belongs_to(:disruption_revision, Arrow.DisruptionRevision)

    timestamps(type: :utc_datetime)
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t(t())
  def changeset(exception, attrs) do
    exception
    |> cast(attrs, [:excluded_date])
    |> validate_required([:excluded_date])
  end
end
