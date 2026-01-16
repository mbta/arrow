defmodule Arrow.Disruption.Exception do
  @moduledoc """
  Dates within a disruption's time frame for which it does not apply.
  """

  use Arrow.Schema
  import Ecto.Changeset

  typed_schema "disruption_exceptions" do
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
