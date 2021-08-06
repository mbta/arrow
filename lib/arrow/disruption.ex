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
          published_revision: DisruptionRevision.t() | Ecto.Association.NotLoaded.t(),
          last_published_at: DateTime.t() | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "disruptions" do
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
  Given a query with a Disruption binding `disruptions`, adds a DisruptionRevision binding
  `revisions` that is the latest revisions of each disruption.
  """
  @spec with_latest_revisions(Ecto.Query.t()) :: Ecto.Query.t()
  def with_latest_revisions(query \\ from(d in __MODULE__, as: :disruptions)) do
    from([latest_ids: l] in with_latest_revision_ids(query),
      join: r in DisruptionRevision,
      on: r.id == l.latest_revision_id,
      as: :revisions
    )
  end

  @doc """
  Given a query with a Disruption binding `disruptions`, adds a binding `latest_ids` with fields
  `disruption_id` and `latest_revision_id`, indicating the latest revision of each disruption.
  """
  @spec with_latest_revision_ids(Ecto.Query.t()) :: Ecto.Query.t()
  def with_latest_revision_ids(query \\ from(d in __MODULE__, as: :disruptions)) do
    latest_ids =
      from(r in DisruptionRevision,
        group_by: r.disruption_id,
        select: %{disruption_id: r.disruption_id, latest_revision_id: max(r.id)}
      )

    from([disruptions: d] in query,
      join: l in subquery(latest_ids),
      on: l.disruption_id == d.id,
      as: :latest_ids
    )
  end

  @doc """
  Returns all the disruptions whose latest and published revisions are different,
  preloaded with the latest revision, and published revision if there is one.
  Order of revisions is not guaranteed
  """
  @spec latest_vs_published() :: {[t()], [t()]}
  def latest_vs_published do
    from([disruptions: d, latest_ids: l] in with_latest_revision_ids(),
      join: r in assoc(d, :revisions),
      on: r.disruption_id == d.id,
      where: is_nil(d.published_revision_id) or d.published_revision_id != l.latest_revision_id,
      where: r.id == d.published_revision_id or r.id == l.latest_revision_id,
      preload: [revisions: {r, ^DisruptionRevision.associations()}]
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
