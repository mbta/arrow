defmodule Arrow.DisruptionRevision do
  use Ecto.Schema
  import Ecto.Query

  alias Arrow.Disruption
  alias Arrow.Disruption.DayOfWeek
  alias Arrow.Disruption.Exception
  alias Arrow.Disruption.TripShortName

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
  def ready_all!() do
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

  @spec publish!([integer()]) :: :ok
  def publish!(ids) do
    Arrow.Repo.transaction(fn ->
      {updated, _} =
        from(d in Arrow.Disruption,
          join: dr in __MODULE__,
          on: dr.disruption_id == d.id,
          where: dr.id in ^ids and dr.id <= d.ready_revision_id,
          update: [set: [published_revision_id: dr.id]]
        )
        |> Arrow.Repo.update_all([])

      if updated != Enum.count(ids) do
        raise Disruption.PublishedAfterReadyError
      end
    end)

    :ok
  end

  @spec diff(t(), t()) :: [String.t()]
  def diff(%__MODULE__{} = dr1, %__MODULE__{} = dr2) do
    was_deleted(dr1.is_active, dr2.is_active) ++
      field_change(dr1.start_date, dr2.start_date, "Start date") ++
      field_change(dr1.end_date, dr2.end_date, "End date") ++
      exceptions_diff(dr1.exceptions, dr2.exceptions) ++
      trip_short_names_diff(dr1.trip_short_names, dr2.trip_short_names) ++
      days_of_week_diff(dr1.days_of_week, dr2.days_of_week)
  end

  @spec was_deleted(boolean(), boolean()) :: [String.t()]
  defp was_deleted(true, false), do: ["Disruption was deleted"]
  defp was_deleted(_, _), do: []

  @spec field_change(String.Chars.t(), String.Chars.t(), String.t()) :: [String.t()]
  defp field_change(val1, val2, field) do
    if val1 != val2 do
      [field <> " changed from #{val1} to #{val2}"]
    else
      []
    end
  end

  @spec exceptions_diff([Exception.t()], [Exception.t()]) :: [String.t()]
  defp exceptions_diff(exc1, exc2) do
    dates1 = Enum.map(exc1, & &1.excluded_date)
    dates2 = Enum.map(exc2, & &1.excluded_date)

    list_edits("The following exception dates", dates1, dates2)
  end

  @spec trip_short_names_diff([TripShortName.t()], [TripShortName.t()]) :: [String.t()]
  defp trip_short_names_diff(tsn1, tsn2) do
    names1 = Enum.map(tsn1, & &1.trip_short_name)
    names2 = Enum.map(tsn2, & &1.trip_short_name)

    list_edits("The following trip short names", names1, names2)
  end

  @spec days_of_week_diff([DayOfWeek.t()], [DayOfWeek.t()]) :: [String.t()]
  defp days_of_week_diff(dow1, dow2) do
    Enum.reduce(
      ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"],
      [],
      fn day_name, acc ->
        d1 = Enum.find(dow1, &(&1.day_name == day_name))
        d2 = Enum.find(dow2, &(&1.day_name == day_name))

        cond do
          is_nil(d1) and is_nil(d2) ->
            acc

          is_nil(d1) ->
            ["Added #{day_name}" | acc]

          is_nil(d2) ->
            ["Removed #{day_name}" | acc]

          true ->
            acc =
              if d1.start_time != d2.start_time do
                [
                  "Changed #{day_name} start time from #{d1.start_time || "SoS"} to #{
                    d2.start_time || "SoS"
                  }"
                ]
              else
                acc
              end

            acc =
              if d1.end_time != d2.end_time do
                [
                  "Changed #{day_name} end time from #{d1.end_time || "EoS"} to #{
                    d2.end_time || "EoS"
                  }"
                ]
              else
                acc
              end

            acc
        end
      end
    )
  end

  @spec list_edits(String.t(), [String.Chars.t()], [String.Chars.t()]) :: [String.t()]
  defp list_edits(prefix, l1, l2) do
    deleted = l1 -- l2
    inserted = l2 -- l1

    deleted_msg =
      if deleted != [] do
        ["#{prefix} were deleted: #{Enum.join(deleted, ",")}"]
      else
        []
      end

    added_msg =
      if inserted != [] do
        ["#{prefix} were added: #{Enum.join(inserted, ",")}"]
      else
        []
      end

    added_msg ++ deleted_msg
  end
end
