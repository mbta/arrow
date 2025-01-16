defmodule Arrow.Limits.LimitDayOfWeek do
  @moduledoc "schema for a limit day of week for the db"

  use Ecto.Schema
  import Ecto.Changeset

  alias Arrow.Disruptions.Limit

  @type t :: %__MODULE__{
          day_name: String.t(),
          start_time: Time.t() | nil,
          end_time: Time.t() | nil,
          active?: boolean(),
          all_day?: boolean(),
          limit: Limit.t() | Ecto.Association.NotLoaded.t()
        }

  schema "limit_day_of_weeks" do
    field :day_name, :string
    field :start_time, :time
    field :end_time, :time
    field :active?, :boolean, source: :is_active, default: false
    field :all_day?, :boolean, virtual: true
    belongs_to :limit, Arrow.Disruptions.Limit

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(limit_day_of_week, attrs \\ %{}) do
    limit_day_of_week
    |> cast(attrs, [:active?, :day_name, :start_time, :end_time, :limit_id, :all_day?])
    |> validate_required([:day_name])
    |> validate_inclusion(:day_name, [
      "monday",
      "tuesday",
      "wednesday",
      "thursday",
      "friday",
      "saturday",
      "sunday"
    ])
    |> validate_required_times()
    |> validate_start_time_before_end_time()
    |> assoc_constraint(:limit)
  end

  @spec validate_required_times(Ecto.Changeset.t(t())) :: Ecto.Changeset.t(t())
  defp validate_required_times(changeset) do
    cond do
      not get_field(changeset, :active?) ->
        changeset

      get_field(changeset, :all_day?) ->
        Ecto.Changeset.change(changeset, %{start_time: nil, end_time: nil})

      true ->
        validate_required(changeset, [:start_time, :end_time])
    end
  end

  @spec validate_start_time_before_end_time(Ecto.Changeset.t(t())) :: Ecto.Changeset.t(t())
  defp validate_start_time_before_end_time(changeset) do
    start_time = get_field(changeset, :start_time)
    end_time = get_field(changeset, :end_time)

    cond do
      is_nil(start_time) or is_nil(end_time) ->
        changeset

      not (Time.compare(start_time, end_time) == :lt) ->
        add_error(changeset, :start_time, "start time should be before end time")

      true ->
        changeset
    end
  end
end
