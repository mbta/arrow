defmodule Arrow.Limits.LimitDayOfWeek do
  @moduledoc "schema for a limit day of week for the db"

  use Arrow.Schema
  import Ecto.Changeset
  import Arrow.Util.DayOfWeek

  @type day_name :: Arrow.Util.DayOfWeek.day_name()

  typed_schema "limit_day_of_weeks" do
    field :day_name, Ecto.Enum, values: day_name_values()
    field :start_time, :string
    field :end_time, :string
    field :active?, :boolean, source: :is_active, default: false
    field :all_day?, :boolean, virtual: true
    belongs_to :limit, Arrow.Disruptions.Limit

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(limit_day_of_week, attrs \\ %{}, opts \\ []) do
    time_regex = ~r/^\d{2}:[0-5][0-9]$/

    limit_day_of_week
    |> cast(attrs, [:active?, :day_name, :start_time, :end_time, :limit_id, :all_day?])
    |> validate_required([:day_name])
    |> validate_required_times()
    |> validate_format(:start_time, time_regex,
      message: "must be a valid GTFS time in format HH:MM"
    )
    |> validate_format(:end_time, time_regex,
      message: "must be a valid GTFS time in format HH:MM"
    )
    |> validate_start_time_before_end_time()
    |> validate_in_date_range(opts[:date_range_day_of_weeks])
    |> assoc_constraint(:limit)
  end

  @spec validate_in_date_range(Ecto.Changeset.t(t()), MapSet.t(day_name) | nil) ::
          Ecto.Changeset.t(t())
  defp validate_in_date_range(changeset, nil), do: changeset

  defp validate_in_date_range(changeset, day_of_weeks) do
    day_name = get_field(changeset, :day_name)

    if get_field(changeset, :active?) and day_name not in day_of_weeks do
      day_name = day_name |> Atom.to_string() |> String.capitalize()
      msg = "Dates specified above do not include a #{day_name}"
      add_error(changeset, :day_name, msg)
    else
      changeset
    end
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

    if changeset.valid? and not is_nil(start_time) and not is_nil(end_time) do
      [start_hour, start_minute] = String.split(start_time, ":")
      [end_hour, end_minute] = String.split(end_time, ":")

      start_dt = parse_time_string(start_hour, start_minute)
      end_dt = parse_time_string(end_hour, end_minute)

      if DateTime.before?(start_dt, end_dt) do
        changeset
      else
        add_error(changeset, :start_time, "start time should be before end time")
      end
    else
      changeset
    end
  end

  defp parse_time_string(hour, minute) do
    hour_as_integer = String.to_integer(hour)

    {:ok, dt, _} =
      if hour_as_integer < 24 do
        DateTime.from_iso8601("2025-01-01T#{hour}:#{minute}:00Z")
      else
        hour = (hour_as_integer - 24) |> to_string() |> String.pad_leading(2, "0")

        DateTime.from_iso8601("2025-01-02T#{hour}:#{minute}:00Z")
      end

    dt
  end

  @spec day_number(t() | day_name) :: 1..7
  def day_number(%__MODULE__{} = dow), do: day_number(dow.day_name)

  for {name, number} <- Arrow.Util.DayOfWeek.day_name_values() do
    def day_number(unquote(name)), do: unquote(number)
  end

  @spec set_all_day_default(t()) :: t()
  def set_all_day_default(day_of_week) do
    %{
      day_of_week
      | all_day?:
          day_of_week.active? and is_nil(day_of_week.start_time) and
            is_nil(day_of_week.end_time)
    }
  end
end
