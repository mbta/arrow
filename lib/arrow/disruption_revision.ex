defmodule Arrow.DisruptionRevision do
  @moduledoc """
  A particular version of a Disruption, in that Disruption's creation/edit/deletion life cycle.
  """

  use Ecto.Schema
  import Ecto.Query

  alias Arrow.{Disruption, Repo}
  alias Arrow.Disruption.{DayOfWeek, Exception, TripShortName}

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
    field(:end_date, :date)
    field(:start_date, :date)
    field(:is_active, :boolean)

    belongs_to(:disruption, Disruption)
    has_many(:days_of_week, DayOfWeek, on_replace: :delete)
    has_many(:exceptions, Exception, on_replace: :delete)
    has_many(:trip_short_names, TripShortName, on_replace: :delete)
    many_to_many(:adjustments, Arrow.Adjustment, join_through: "disruption_adjustments")

    timestamps(type: :utc_datetime)
  end

  @associations [:days_of_week, :exceptions, :trip_short_names, :adjustments]

  @spec associations() :: [atom()]
  def associations do
    @associations
  end

  @spec only_ready(Ecto.Queryable.t()) :: Ecto.Query.t()
  def only_ready(query) do
    ready_ids = from(d in Disruption, select: d.ready_revision_id)

    from(dr in query, where: dr.id in subquery(ready_ids) and dr.is_active)
  end

  @spec latest_revision(Ecto.Queryable.t()) :: Ecto.Query.t()
  def latest_revision(query) do
    draft_ids = from(dr in __MODULE__, select: %{id: max(dr.id)}, group_by: dr.disruption_id)

    from(dr in query, where: dr.id in subquery(draft_ids) and dr.is_active)
  end

  @spec clone!(integer()) :: __MODULE__.t()
  def clone!(disruption_revision_id) do
    disruption_revision =
      Arrow.DisruptionRevision
      |> Arrow.Repo.get!(disruption_revision_id)
      |> Arrow.Repo.preload(@associations)

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

  @spec ready_all!() :: :ok
  def ready_all! do
    draft_map =
      from(dr in Arrow.DisruptionRevision,
        select: %{disruption_id: dr.disruption_id, draft_id: max(dr.id)},
        group_by: dr.disruption_id
      )

    from(d in Arrow.Disruption,
      join: dm in subquery(draft_map),
      on: dm.disruption_id == d.id,
      where: is_nil(d.ready_revision_id) or dm.draft_id != d.ready_revision_id,
      update: [set: [ready_revision_id: dm.draft_id]]
    )
    |> Arrow.Repo.update_all([])

    :ok
  end

  @spec ready!([integer()]) :: :ok
  def ready!(ids) do
    Arrow.Repo.transaction(fn ->
      draft_map =
        from(dr in Arrow.DisruptionRevision,
          select: %{disruption_id: dr.disruption_id, draft_id: max(dr.id)},
          group_by: dr.disruption_id
        )

      {updated, _} =
        from(d in Arrow.Disruption,
          join: dm in subquery(draft_map),
          on: dm.disruption_id == d.id,
          where:
            dm.draft_id in type(^ids, {:array, :integer}) and
              (is_nil(d.ready_revision_id) or
                 dm.draft_id != d.ready_revision_id),
          update: [set: [ready_revision_id: dm.draft_id]]
        )
        |> Arrow.Repo.update_all([])

      if updated != Enum.count(ids) do
        raise Disruption.ReadyNotLatestError
      end
    end)

    :ok
  end

  @spec publish!([integer()]) :: :ok
  def publish!(ids) do
    disruptions_with_revisions =
      from(d in Disruption, join: dr in assoc(d, :revisions), where: dr.id in ^ids)

    Repo.transaction(fn ->
      # Validate each to-be-published revision is older than, or is, the ready revision
      valid_ids_count =
        from([d, dr] in disruptions_with_revisions, where: dr.id <= d.ready_revision_id)
        |> Repo.aggregate(:count)

      if valid_ids_count != length(ids), do: raise(Disruption.PublishedAfterReadyError)

      # Update disruptions only where the published revision is changing
      from([d, dr] in disruptions_with_revisions,
        where: dr.id != d.published_revision_id or is_nil(d.published_revision_id),
        update: [set: [published_revision_id: dr.id, last_published_at: fragment("now()")]]
      )
      |> Repo.update_all([])
    end)

    :ok
  end
end
