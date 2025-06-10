defmodule Arrow.Hastus.Service do
  @moduledoc "schema for a HASTUS service for the db"

  use Ecto.Schema
  import Ecto.Changeset

  alias Arrow.Hastus.{DerivedLimit, Export, ServiceDate}

  @type t :: %__MODULE__{
          name: String.t(),
          service_dates: list(ServiceDate) | Ecto.Association.NotLoaded.t(),
          derived_limits: list(DerivedLimit.t()) | Ecto.Association.NotLoaded.t(),
          import?: boolean(),
          export: Export.t() | Ecto.Association.NotLoaded.t()
        }

  schema "hastus_services" do
    field :name, :string
    field :import?, :boolean, source: :should_import, default: true

    has_many :service_dates, ServiceDate,
      on_replace: :delete,
      foreign_key: :service_id

    has_many :derived_limits, DerivedLimit, on_replace: :delete, foreign_key: :service_id

    belongs_to :export, Arrow.Hastus.Export

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(service, attrs) do
    service
    |> cast(attrs, [:name, :export_id, :import?])
    |> validate_required([:name])
    |> cast_assoc(:service_dates, with: &ServiceDate.changeset/2)
    |> cast_assoc(:derived_limits, with: &DerivedLimit.changeset/2)
    |> assoc_constraint(:export)
  end

  def first_date(%__MODULE__{} = service) do
    service = Arrow.Repo.preload(service, :service_dates)

    service.service_dates
    |> Enum.map(& &1.start_date)
    |> Enum.min(Date)
  end

  def last_date(%__MODULE__{} = service) do
    service = Arrow.Repo.preload(service, :service_dates)

    service.service_dates
    |> Enum.map(& &1.start_date)
    |> Enum.max(Date)
  end

  @doc """
  Returns a set of days-of-week (as integers) covered by all service_dates in a service.
  """
  @spec day_of_weeks(t()) :: MapSet.t(1..7)
  def day_of_weeks(%__MODULE__{} = service) do
    service = Arrow.Repo.preload(service, :service_dates)

    service.service_dates
    |> Enum.map(&ServiceDate.day_of_weeks/1)
    |> Enum.reduce(MapSet.new(), &MapSet.union/2)
  end

  @doc """
  Returns true if `service` has any derived limits.
  """
  @spec has_derived_limits?(t()) :: boolean
  def has_derived_limits?(%__MODULE__{} = service) do
    service = Arrow.Repo.preload(service, [:derived_limits])

    not Enum.empty?(service.derived_limits)
  end
end
