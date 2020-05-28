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

  @spec day_name(1 | 2 | 3 | 4 | 5 | 6 | 7) :: String.t()
  def day_name(1), do: "monday"
  def day_name(2), do: "tuesday"
  def day_name(3), do: "wednesday"
  def day_name(4), do: "thursday"
  def day_name(5), do: "friday"
  def day_name(6), do: "saturday"
  def day_name(7), do: "sunday"

  @spec date_to_day_name(Date.t()) :: String.t()
  def date_to_day_name(date), do: date |> Date.day_of_week() |> day_name()
end
