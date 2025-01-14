defmodule Arrow.Limits.LimitDayOfWeek do
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
    field :active?, :boolean, virtual: true
    field :all_day?, :boolean, virtual: true
    belongs_to :limit, Arrow.Disruptions.Limit

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(limit_day_of_week, attrs \\ %{}) do
    limit_day_of_week
    |> cast(attrs, [:day_name, :start_time, :end_time, :limit_id])
    |> validate_required([:day_name, :start_time, :end_time])
    |> assoc_constraint(:limit)
  end
end
