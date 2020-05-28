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

  @spec day_number(t()) :: 1 | 2 | 3 | 4 | 5 | 6 | 7
  def day_number(%{day_name: "monday"}), do: 1
  def day_number(%{day_name: "tuesday"}), do: 2
  def day_number(%{day_name: "wednesday"}), do: 3
  def day_number(%{day_name: "thursday"}), do: 4
  def day_number(%{day_name: "friday"}), do: 5
  def day_number(%{day_name: "saturday"}), do: 6
  def day_number(%{day_name: "sunday"}), do: 7
end
