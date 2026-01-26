defmodule Arrow.Trainsformer.ServiceDateDayOfWeek do
  @moduledoc "Describes the days of week for which a service should be active, within some date range"

  use Arrow.Schema
  import Ecto.Changeset

  typed_schema "service_date_days_of_week" do
    field :day_name, Ecto.Enum, values: Arrow.Util.DayOfWeek.day_name_values()
    belongs_to :service_date, Arrow.Trainsformer.ServiceDate, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(service_date_days_of_week, attrs) do
    service_date_days_of_week
    |> cast(attrs, [:day_name])
    |> validate_required([:day_name])
    |> assoc_constraint(:service_date)
  end
end
