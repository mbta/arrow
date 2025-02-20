defmodule Arrow.Disruptions.Limit do
  @moduledoc "schema for a limit for the db"

  use Ecto.Schema
  import Ecto.Changeset

  alias Arrow.Disruptions.DisruptionV2
  alias Arrow.Gtfs.{Route, Stop}
  alias Arrow.Limits.LimitDayOfWeek

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
          disruption: DisruptionV2.t() | Ecto.Association.NotLoaded.t(),
          route: Route.t() | Ecto.Association.NotLoaded.t(),
          start_stop: Stop.t() | Ecto.Association.NotLoaded.t(),
          end_stop: Stop.t() | Ecto.Association.NotLoaded.t(),
          limit_day_of_weeks: [LimitDayOfWeek.t()] | Ecto.Association.NotLoaded.t()
        }

  schema "limits" do
    field :start_date, :date
    field :end_date, :date
    field :editing?, :boolean, virtual: true, default: false
    belongs_to :disruption, Arrow.Disruptions.DisruptionV2
    belongs_to :route, Arrow.Gtfs.Route, type: :string
    belongs_to :start_stop, Arrow.Gtfs.Stop, type: :string
    belongs_to :end_stop, Arrow.Gtfs.Stop, type: :string

    has_many :limit_day_of_weeks, Arrow.Limits.LimitDayOfWeek,
      on_replace: :delete,
      preload_order: [:day_name]

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
    |> cast_assoc(:limit_day_of_weeks, with: &Arrow.Limits.LimitDayOfWeek.changeset/2)
    |> validate_required([:start_date, :end_date, :route_id, :start_stop_id, :end_stop_id])
    |> validate_start_date_before_end_date()
    |> assoc_constraint(:route)
    |> assoc_constraint(:start_stop)
    |> assoc_constraint(:end_stop)
    |> assoc_constraint(:disruption)
  end

  @spec validate_start_date_before_end_date(Ecto.Changeset.t(t())) :: Ecto.Changeset.t(t())
  defp validate_start_date_before_end_date(changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)

    cond do
      is_nil(start_date) or is_nil(end_date) ->
        changeset

      not (Date.compare(start_date, end_date) == :lt) ->
        add_error(changeset, :start_date, "start date should be before end date")

      true ->
        changeset
    end
  end

  @doc """
  Constructs a new limit with a default list of `limit_day_of_weeks`.
  """
  @spec new(Enum.t()) :: t()
  def new(attrs \\ %{}) do
    %__MODULE__{limit_day_of_weeks: @default_day_of_weeks_list}
    |> struct!(attrs)
  end

  def display_label(%__MODULE__{start_stop: start_stop, end_stop: end_stop}) do
    "#{start_stop.name} to #{end_stop.name}"
  end

  @spec route(t()) :: atom()
  def route(%__MODULE__{route_id: "Blue"}), do: :blue_line
  def route(%__MODULE__{route_id: "Orange"}), do: :orange_line
  def route(%__MODULE__{route_id: "Red"}), do: :red_line
  def route(%__MODULE__{route_id: "Mattapan"}), do: :mattapan_line
  def route(%__MODULE__{route_id: "Green-B"}), do: :green_line_b
  def route(%__MODULE__{route_id: "Green-C"}), do: :green_line_c
  def route(%__MODULE__{route_id: "Green-D"}), do: :green_line_d
  def route(%__MODULE__{route_id: "Green-E"}), do: :green_line_e
end
