defmodule Arrow.DisruptionRevision do
  use Ecto.Schema
  import Ecto.Query, only: [from: 2]

  alias Arrow.Disruption
  alias Arrow.Disruption.DayOfWeek
  alias Arrow.Disruption.Exception
  alias Arrow.Disruption.TripShortName
  alias Arrow.Repo

  @type t :: %__MODULE__{
          end_date: Date.t() | nil,
          start_date: Date.t() | nil,
          is_active: boolean(),
          disruption: Disruption.t() | Ecto.Association.NotLoaded.t(),
          days_of_week: [DayOfWeek.t()] | Ecto.Association.NotLoaded.t(),
          exceptions: [Exception.t()] | Ecto.Association.NotLoaded.t(),
          trip_short_names: [TripShortName.t()] | Ecto.Association.NotLoaded.t(),
          adjustments: [Arrow.Adjustment.t()] | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  schema "disruption_revisions" do
    field :end_date, :date
    field :start_date, :date
    field :is_active, :boolean

    belongs_to :disruption, Disruption
    has_many :days_of_week, DayOfWeek, on_replace: :delete
    has_many :exceptions, Exception, on_replace: :delete
    has_many :trip_short_names, TripShortName, on_replace: :delete
    many_to_many :adjustments, Arrow.Adjustment, join_through: "disruption_adjustments"

    timestamps(type: :utc_datetime)
  end

  @spec only_published(Ecto.Queryable.t()) :: Ecto.Query.t()
  def only_published(query) do
    published_ids =
      from(d in Disruption, select: d.published_revision_id) |> Repo.all() |> Enum.filter(& &1)

    from(dr in query, where: dr.id in ^published_ids and dr.is_active)
  end

  @spec latest_revision(Ecto.Queryable.t()) :: Ecto.Query.t()
  def latest_revision(query) do
    draft_ids =
      from(dr in __MODULE__, select: max(dr.id), group_by: dr.disruption_id) |> Repo.all()

    from(dr in query, where: dr.id in ^draft_ids)
  end

  @spec clone!(integer()) :: __MODULE__.t()
  def clone!(disruption_revision_id) do
    disruption_revision =
      Arrow.DisruptionRevision
      |> Arrow.Repo.get!(disruption_revision_id)
      |> Arrow.Repo.preload([:adjustments, :days_of_week, :exceptions, :trip_short_names])

    days_of_week =
      for dow <- disruption_revision.days_of_week || [] do
        dow = Map.take(dow, [:day_name, :start_time, :end_time])
        DayOfWeek.changeset(%DayOfWeek{}, dow)
      end

    exceptions =
      for exception <- disruption_revision.exceptions || [] do
        exception = Map.take(exception, [:excluded_date])
        Exception.changeset(%Exception{}, exception)
      end

    trip_short_names =
      for name <- disruption_revision.trip_short_names || [] do
        name = Map.take(name, [:trip_short_name])
        TripShortName.changeset(%TripShortName{}, name)
      end

    adjustments = disruption_revision.adjustments
    disruption_revision = Map.take(disruption_revision, [:disruption_id, :start_date, :end_date])

    %Arrow.DisruptionRevision{is_active: true}
    |> Ecto.Changeset.cast(disruption_revision, [
      :disruption_id,
      :start_date,
      :end_date,
      :is_active
    ])
    |> Ecto.Changeset.validate_required([:disruption_id, :is_active])
    |> Ecto.Changeset.put_assoc(:adjustments, adjustments)
    |> Ecto.Changeset.put_assoc(:days_of_week, days_of_week)
    |> Ecto.Changeset.put_assoc(:exceptions, exceptions)
    |> Ecto.Changeset.put_assoc(:trip_short_names, trip_short_names)
    |> Arrow.Repo.insert!()
  end

  @spec publish_all!() :: :ok
  def publish_all!() do
    draft_map =
      from(dr in Arrow.DisruptionRevision,
        select: %{disruption_id: dr.disruption_id, draft_id: max(dr.id)},
        group_by: dr.disruption_id
      )

    from(d in Arrow.Disruption,
      join: dm in subquery(draft_map),
      on: dm.disruption_id == d.id,
      where: is_nil(d.published_revision_id) or dm.draft_id != d.published_revision_id,
      update: [set: [published_revision_id: dm.draft_id]]
    )
    |> Arrow.Repo.update_all([])

    :ok
  end
end
