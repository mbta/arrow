defmodule Arrow.Trainsformer.ServiceDate do
  @moduledoc "schema for a Trainsformer service date"

  use Arrow.Schema
  import Ecto.Changeset
  alias Arrow.Trainsformer.ServiceDateDayOfWeek

  typed_schema "trainsformer_service_dates" do
    field :start_date, :date
    field :end_date, :date
    belongs_to :service, Arrow.Trainsformer.Service, on_replace: :delete

    has_many :service_date_days_of_week, ServiceDateDayOfWeek,
      on_replace: :delete,
      foreign_key: :service_date_id
  end

  defp transform_form_submission(attrs) do
    with %{"service_date_days_of_week" => sddow} <- attrs,
         [_ | _] <- sddow do
      formatted_days =
        Enum.map(sddow, fn day ->
          %{
            "day_name" => day
          }
        end)

      %{attrs | "service_date_days_of_week" => formatted_days}
    else
      _ -> attrs
    end
  end

  @doc false
  def changeset(service_date, attrs) do
    transformed_attrs = transform_form_submission(attrs)

    service_date
    |> cast(transformed_attrs, [:start_date, :end_date, :service_id])
    |> cast_assoc(:service_date_days_of_week, with: &ServiceDateDayOfWeek.changeset/2)
    |> validate_required([:start_date, :end_date])
    |> Arrow.Util.validate_start_date_before_end_date()
    |> assoc_constraint(:service)
  end
end
