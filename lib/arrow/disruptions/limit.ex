defmodule Arrow.Disruptions.Limit do
  @moduledoc "schema for a limit for the db"

  use Ecto.Schema

  import Ecto.Changeset

  alias Arrow.Disruptions.DisruptionV2
  alias Arrow.Gtfs.Route
  alias Arrow.Gtfs.Stop
  alias Arrow.Limits.LimitDayOfWeek
  alias Ecto.Association.NotLoaded

  @default_day_of_weeks_list [
    %LimitDayOfWeek{day_name: :monday},
    %LimitDayOfWeek{day_name: :tuesday},
    %LimitDayOfWeek{day_name: :wednesday},
    %LimitDayOfWeek{day_name: :thursday},
    %LimitDayOfWeek{day_name: :friday},
    %LimitDayOfWeek{day_name: :saturday},
    %LimitDayOfWeek{day_name: :sunday}
  ]

  @type t :: %__MODULE__{
          start_date: Date.t() | nil,
          end_date: Date.t() | nil,
          disruption: DisruptionV2.t() | NotLoaded.t(),
          route: Route.t() | NotLoaded.t(),
          start_stop: Stop.t() | NotLoaded.t(),
          end_stop: Stop.t() | NotLoaded.t(),
          limit_day_of_weeks: [LimitDayOfWeek.t()] | NotLoaded.t()
        }

  schema "limits" do
    field :start_date, :date
    field :end_date, :date
    field :check_for_overlap, :boolean, default: true
    field :editing?, :boolean, virtual: true, default: false
    belongs_to :disruption, DisruptionV2
    belongs_to :route, Route, type: :string
    belongs_to :start_stop, Stop, type: :string
    belongs_to :end_stop, Stop, type: :string
    has_many :limit_day_of_weeks, LimitDayOfWeek, on_replace: :delete, preload_order: [:day_name]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(limit, attrs) do
    limit
    |> cast(attrs, [
      :start_date,
      :end_date,
      :route_id,
      :start_stop_id,
      :end_stop_id,
      :disruption_id,
      :editing?
    ])
    |> put_change(:check_for_overlap, true)
    |> validate_required([:start_date, :end_date, :route_id, :start_stop_id, :end_stop_id])
    |> validate_start_date_before_end_date()
    |> cast_assoc_day_of_weeks()
    |> exclusion_constraint(:end_date,
      name: :no_overlap,
      message: "cannot overlap another limit"
    )
    |> assoc_constraint(:route)
    |> assoc_constraint(:start_stop)
    |> assoc_constraint(:end_stop)
    |> assoc_constraint(:disruption)
    |> validate_change(:limit_day_of_weeks, fn
      :limit_day_of_weeks, value when is_list(value) ->
        if Enum.any?(value, &get_field(&1, :active?, false)) do
          []
        else
          [limit_day_of_weeks: "at least one day of week must be active"]
        end
    end)
  end

  @doc """
  Constructs a new limit with a default list of `limit_day_of_weeks`.
  """
  @spec new(Enum.t()) :: t()
  def new(attrs \\ %{}) do
    struct!(%__MODULE__{limit_day_of_weeks: @default_day_of_weeks_list}, attrs)
  end

  @spec validate_start_date_before_end_date(Ecto.Changeset.t(t())) :: Ecto.Changeset.t(t())
  defp validate_start_date_before_end_date(changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)

    cond do
      is_nil(start_date) or is_nil(end_date) ->
        changeset

      Date.after?(start_date, end_date) ->
        add_error(changeset, :start_date, "start date should not be after end date")

      true ->
        changeset
    end
  end

  @spec cast_assoc_day_of_weeks(Ecto.Changeset.t(t())) :: Ecto.Changeset.t(t())
  defp cast_assoc_day_of_weeks(changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)
    dow_in_range = dow_in_date_range(start_date, end_date)

    cast_assoc(changeset, :limit_day_of_weeks,
      with: &LimitDayOfWeek.changeset(&1, &2, date_range_day_of_weeks: dow_in_range)
    )
  end

  @spec dow_in_date_range(Date.t() | nil, Date.t() | nil) :: MapSet.t(LimitDayOfWeek.day_name())
  defp dow_in_date_range(start_date, end_date) when is_nil(start_date) when is_nil(end_date) do
    MapSet.new(~w[monday tuesday wednesday thursday friday saturday sunday]a)
  end

  defp dow_in_date_range(start_date, end_date) do
    start_date
    |> Date.range(end_date)
    |> Stream.take(7)
    |> MapSet.new(&(&1 |> Date.day_of_week() |> LimitDayOfWeek.day_name()))
  end
end
