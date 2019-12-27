defmodule Arrow.Disruption.Exception do
  use Ecto.Schema
  import Ecto.Changeset

  schema "disruption_exceptions" do
    field :excluded_date, :date
    belongs_to :disruption, Arrow.Disruption

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(exception, attrs) do
    exception
    |> cast(attrs, [:excluded_date])
    |> validate_required([:excluded_date])
  end
end
