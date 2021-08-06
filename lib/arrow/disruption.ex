defmodule Arrow.Disruption do
  @moduledoc """
  Disruption: the configuration of trips to which one or more Adjustment(s) is applied.

  - Specific adjustment(s)
  - Dates and times
  - Trip short names (Commuter Rail only)
  """
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Arrow.Disruption.{DayOfWeek, Exception, TripShortName}
  alias Arrow.DisruptionRevision

  @type t :: %__MODULE__{
          ready_revision: DisruptionRevision.t() | Ecto.Association.NotLoaded.t(),
          published_revision: DisruptionRevision.t() | Ecto.Association.NotLoaded.t(),
          last_published_at: DateTime.t() | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "disruptions" do
    belongs_to :ready_revision, DisruptionRevision
    belongs_to :published_revision, DisruptionRevision
    has_many :revisions, DisruptionRevision

    field(:last_published_at, :utc_datetime)

    timestamps(type: :utc_datetime)
  end

  @spec create(map(), [Arrow.Adjustment.t()]) ::
          {:ok, __MODULE__.t()} | {:error, any()}
  def create(attrs, adjustments) do
    days_of_week =
      for dow <- attrs["days_of_week"] || [],
          do: DayOfWeek.changeset(%DayOfWeek{}, dow)

    exceptions =
      for exception <- attrs["exceptions"] || [],
          do: Exception.changeset(%Exception{}, exception)

    trip_short_names =
      for name <- attrs["trip_short_names"] || [],
          do: TripShortName.changeset(%TripShortName{}, name)

    disruption = Arrow.Repo.insert!(%__MODULE__{})

    dr_params =
      attrs
      |> Map.take(["start_date", "end_date"])
      |> Map.put("disruption_id", disruption.id)

    disruption_revision_changeset =
      %DisruptionRevision{}
      |> Ecto.Changeset.cast(dr_params, [:disruption_id, :start_date, :end_date])
      |> Ecto.Changeset.validate_required([:disruption_id, :start_date, :end_date])
      |> Ecto.Changeset.put_assoc(:adjustments, adjustments)
      |> Ecto.Changeset.put_assoc(:days_of_week, days_of_week)
      |> Ecto.Changeset.put_assoc(:exceptions, exceptions)
      |> Ecto.Changeset.put_assoc(:trip_short_names, trip_short_names)
      |> validate_length(:adjustments, min: 1)
      |> common_validations()

    case Arrow.Repo.insert(disruption_revision_changeset) do
      {:ok, _disruption_revision} ->
        {:ok, disruption}

      {:error, err} ->
        Arrow.Repo.delete!(disruption)
        {:error, err}
    end
  end

  @spec update(integer(), map()) :: {:ok, __MODULE__.t()} | {:error, any()}
  def update(disruption_revision_id, attrs) do
    new_disruption_revision = DisruptionRevision.clone!(disruption_revision_id)

    dr =
      Arrow.Repo.get(DisruptionRevision, new_disruption_revision.id)
      |> Arrow.Repo.preload(DisruptionRevision.associations())

    dr_changeset =
      dr
      |> Ecto.Changeset.cast(attrs, [:start_date, :end_date])
      |> Ecto.Changeset.validate_required([:disruption_id, :start_date, :end_date])
      |> Ecto.Changeset.cast_assoc(:days_of_week)
      |> Ecto.Changeset.cast_assoc(:exceptions)
      |> Ecto.Changeset.cast_assoc(:trip_short_names)
      |> common_validations()

    case Arrow.Repo.update(dr_changeset) do
      {:ok, disruption_revision} ->
        {:ok, Arrow.Repo.get!(__MODULE__, disruption_revision.disruption_id)}

      {:error, e} ->
        Arrow.Repo.delete!(dr)
        {:error, e}
    end
  end

  @spec delete(integer()) :: {:ok, DisruptionRevision.t()}
  def delete(disruption_revision_id) do
    new_disruption_revision = DisruptionRevision.clone!(disruption_revision_id)

    disruption_revision =
      Arrow.Repo.get(DisruptionRevision, new_disruption_revision.id)
      |> change(%{is_active: false})
      |> Arrow.Repo.update!()

    {:ok, disruption_revision}
  end

  @doc """
  Returns all the disruptions whose draft and ready revisions are
  different, preloaded with all the revisions between the two.
  """
  @spec draft_vs_ready() :: {[t()], [t()]}
  def draft_vs_ready do
    draft_map =
      from(dr in DisruptionRevision,
        select: %{disruption_id: dr.disruption_id, draft_id: max(dr.id)},
        group_by: dr.disruption_id
      )

    updated =
      from(d in Arrow.Disruption,
        join: dm in subquery(draft_map),
        as: :draft_map,
        on: dm.disruption_id == d.id,
        join: dr in assoc(d, :revisions),
        on: dr.disruption_id == d.id,
        where: d.ready_revision_id != dm.draft_id,
        where: dr.id >= d.ready_revision_id and dr.id <= as(:draft_map).draft_id,
        preload: [revisions: {dr, ^DisruptionRevision.associations()}]
      )
      |> Arrow.Repo.all()

    new =
      from(d in Arrow.Disruption, where: is_nil(d.ready_revision_id))
      |> Arrow.Repo.all()
      |> Arrow.Repo.preload(revisions: DisruptionRevision.associations())

    {updated, new}
  end

  @doc """
  Takes a disruption query (or starts a new one for Arrow.Disruption) and adds a new named join
  to it with a column `latest_revision_id` which is that Disruption's latest revision.

  Usage: from([disruption, latest_revisions] in with_latest_revision_id(), ...)
  """
  @spec with_latest_revision_id(Ecto.Queryable.t()) :: Ecto.Query.t()
  def with_latest_revision_id(disruption_query \\ __MODULE__) do
    latest_map =
      from(dr in DisruptionRevision,
        group_by: dr.disruption_id,
        select: %{disruption_id: dr.disruption_id, latest_revision_id: max(dr.id)}
      )

    from(d in disruption_query,
      join: lm in subquery(latest_map),
      as: :latest,
      on: lm.disruption_id == d.id
    )
  end

  @doc """
  Returns all the disruptions whose latest and published revisions are different,
  preloaded with the latest revision, and published revision if there is one.
  Order of revisions is not guaranteed
  """
  @spec latest_vs_published() :: {[t()], [t()]}
  def latest_vs_published do
    from([d, latest] in with_latest_revision_id(),
      join: dr in assoc(d, :revisions),
      on: dr.disruption_id == d.id,
      where:
        is_nil(d.published_revision_id) or d.published_revision_id != latest.latest_revision_id,
      where: dr.id == d.published_revision_id or dr.id == latest.latest_revision_id,
      preload: [revisions: {dr, ^DisruptionRevision.associations()}]
    )
    |> Arrow.Repo.all()
  end

  @spec common_validations(Ecto.Changeset.t()) :: Ecto.Changeset.t(t())
  defp common_validations(changeset) do
    changeset
    |> validate_start_date_before_end_date()
    |> validate_days_of_week_between_start_and_end_date()
    |> validate_exceptions_between_start_and_end_date()
    |> validate_exceptions_are_unique()
    |> validate_exceptions_are_applicable()
    |> validate_length(:adjustments, min: 1)
    |> validate_length(:days_of_week, min: 1)
  end

  @spec validate_start_date_before_end_date(Ecto.Changeset.t(t())) :: Ecto.Changeset.t(t())
  defp validate_start_date_before_end_date(changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)

    cond do
      is_nil(start_date) or is_nil(end_date) ->
        changeset

      Date.compare(start_date, end_date) == :gt ->
        add_error(changeset, :start_date, "can't be after end date.")

      true ->
        changeset
    end
  end

  @spec validate_days_of_week_between_start_and_end_date(Ecto.Changeset.t(t())) ::
          Ecto.Changeset.t(t())
  defp validate_days_of_week_between_start_and_end_date(changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)
    days_of_week = get_field(changeset, :days_of_week, [])

    cond do
      is_nil(start_date) or is_nil(end_date) ->
        changeset

      Date.diff(end_date, start_date) >= 6 ->
        changeset

      Enum.all?(days_of_week, fn day ->
        Enum.member?(
          Enum.map(Date.range(start_date, end_date), fn date -> Date.day_of_week(date) end),
          DayOfWeek.day_number(day)
        )
      end) ->
        changeset

      true ->
        add_error(changeset, :days_of_week, "should fall between start and end dates")
    end
  end

  @spec validate_exceptions_are_unique(Ecto.Changeset.t(t())) :: Ecto.Changeset.t(t())
  defp validate_exceptions_are_unique(changeset) do
    exceptions = get_field(changeset, :exceptions, [])

    if Enum.uniq_by(exceptions, fn %{excluded_date: excluded_date} -> excluded_date end) ==
         exceptions do
      changeset
    else
      add_error(changeset, :exceptions, "should be unique")
    end
  end

  @spec validate_exceptions_between_start_and_end_date(Ecto.Changeset.t(t())) ::
          Ecto.Changeset.t(t())
  defp validate_exceptions_between_start_and_end_date(changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)
    exceptions = get_field(changeset, :exceptions, [])

    cond do
      is_nil(start_date) or is_nil(end_date) ->
        changeset

      Enum.all?(exceptions, fn exception ->
        Enum.member?([:lt, :eq], Date.compare(start_date, exception.excluded_date)) and
            Enum.member?([:gt, :eq], Date.compare(end_date, exception.excluded_date))
      end) ->
        changeset

      true ->
        add_error(changeset, :exceptions, "should fall between start and end dates")
    end
  end

  @spec validate_exceptions_are_applicable(Ecto.Changeset.t(t())) ::
          Ecto.Changeset.t(t())
  defp validate_exceptions_are_applicable(changeset) do
    days_of_week = get_field(changeset, :days_of_week, [])
    exceptions = get_field(changeset, :exceptions, [])

    day_of_week_numbers = Enum.map(days_of_week, fn x -> DayOfWeek.day_number(x) end)

    if Enum.all?(exceptions, fn exception ->
         Enum.member?(day_of_week_numbers, Date.day_of_week(exception.excluded_date))
       end) do
      changeset
    else
      add_error(changeset, :exceptions, "should be applicable to days of week")
    end
  end
end
