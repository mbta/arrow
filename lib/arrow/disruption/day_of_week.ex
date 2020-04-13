defmodule Arrow.Disruption.DayOfWeek do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          day_name: String.t() | nil,
          start_time: Time.t() | nil,
          end_time: Time.t() | nil,
          disruption: Arrow.Disruption | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  schema "disruption_day_of_weeks" do
    field :day_name, :string
    field :start_time, :time
    field :end_time, :time
    belongs_to :disruption, Arrow.Disruption

    timestamps(type: :utc_datetime)
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(day_of_week, attrs) do
    day_of_week
    |> cast(attrs, [:id, :day_name, :start_time, :end_time])
    |> validate_inclusion(:day_name, [
      "monday",
      "tuesday",
      "wednesday",
      "thursday",
      "friday",
      "saturday",
      "sunday"
    ])
    |> unique_constraint(:day_name, name: "unique_disruption_weekday")
  end
end
