defmodule Arrow.Limits.LimitDayOfWeek do
  @moduledoc "schema for a limit day of week for the db"

  use Ecto.Schema
  import Ecto.Changeset

  alias Arrow.Disruptions.Limit

  @day_name_values Enum.with_index(
                     ~w[monday tuesday wednesday thursday friday saturday sunday]a,
                     1
                   )

  @type t :: %__MODULE__{
          day_name: integer(),
          start_time: String.t() | nil,
          end_time: String.t() | nil,
          active?: boolean(),
          all_day?: boolean(),
          limit: Limit.t() | Ecto.Association.NotLoaded.t()
        }

  schema "limit_day_of_weeks" do
    field :day_name, Ecto.Enum, values: @day_name_values
    field :start_time, :string
    field :end_time, :string
    field :active?, :boolean, source: :is_active, default: false
    field :all_day?, :boolean, virtual: true
    belongs_to :limit, Arrow.Disruptions.Limit

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(limit_day_of_week, attrs \\ %{}) do
    time_regex = ~r/^\d{2}:\d{2}$/

    limit_day_of_week
    |> cast(attrs, [:active?, :day_name, :start_time, :end_time, :limit_id, :all_day?])
    |> validate_required([:day_name])
    |> validate_required_times()
    |> validate_format(:start_time, time_regex, message: "must be in format HH:MM")
    |> validate_format(:end_time, time_regex, message: "must be in format HH:MM")
    |> validate_start_time_before_end_time()
    |> assoc_constraint(:limit)
  end

  @spec validate_required_times(Ecto.Changeset.t(t())) :: Ecto.Changeset.t(t())
  defp validate_required_times(changeset) do
    all_day? = get_field(changeset, :all_day?) || false
    active? = get_field(changeset, :active?) || false

    if all_day? or not active? do
      changeset
    else
      validate_required(changeset, [:start_time, :end_time])
    end
  end

  @spec validate_start_time_before_end_time(Ecto.Changeset.t(t())) :: Ecto.Changeset.t(t())
  defp validate_start_time_before_end_time(changeset) do
    start_time = get_field(changeset, :start_time)
    end_time = get_field(changeset, :end_time)

    if is_nil(start_time) or is_nil(end_time) do
      changeset
    else
      start_time_split = String.split(start_time, ":")
      end_time_split = String.split(end_time, ":")

      if List.first(start_time_split) < List.first(end_time_split) do
        changeset
      else
        add_error(changeset, :start_time, "start time should be before end time")
      end
    end
  end
end
