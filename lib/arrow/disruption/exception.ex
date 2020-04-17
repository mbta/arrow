defmodule Arrow.Disruption.Exception do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          excluded_date: Date.t() | nil,
          disruption: Arrow.Disruption | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  schema "disruption_exceptions" do
    field :excluded_date, :date
    belongs_to :disruption, Arrow.Disruption

    timestamps(type: :utc_datetime)
  end

  @doc false
  @spec changeset(t(), map(), Date.t()) :: Ecto.Changeset.t(t())
  def changeset(exception, attrs, today) do
    exception
    |> cast(attrs, [:id, :excluded_date])
    |> validate_required([:excluded_date])
    |> Arrow.Validations.validate_not_in_past(:excluded_date, today)
    |> Arrow.Validations.validate_not_changing_past(:excluded_date, today)
  end
end
