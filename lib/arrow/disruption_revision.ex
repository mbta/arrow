defmodule Arrow.DisruptionRevision do
  @moduledoc """
  A particular version of a Disruption, in that Disruption's creation/edit/deletion life cycle.
  """

  use Ecto.Schema
  import Ecto.Query

  alias Arrow.{Adjustment, Disruption, Repo}
  alias Arrow.Disruption.{DayOfWeek, Exception, TripShortName}
  alias Ecto.Changeset

  @type id :: integer
  @type t :: %__MODULE__{
          id: id,
          end_date: Date.t() | nil,
          start_date: Date.t() | nil,
          row_approved: boolean(),
          is_active: boolean(),
          description: String.t(),
          adjustment_kind: atom() | nil,
          note_body: String.t() | nil,
          disruption: Disruption.t() | Ecto.Association.NotLoaded.t(),
          days_of_week: [DayOfWeek.t()] | Ecto.Association.NotLoaded.t(),
          exceptions: [Exception.t()] | Ecto.Association.NotLoaded.t(),
          trip_short_names: [TripShortName.t()] | Ecto.Association.NotLoaded.t(),
          adjustments: [Adjustment.t()] | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil,
          title: String.t()
        }

  schema "disruption_revisions" do
    field(:end_date, :date)
    field(:start_date, :date)
    field(:is_active, :boolean)
    field(:row_approved, :boolean, default: true)
    field(:description, :string)
    field(:adjustment_kind, Ecto.Enum, values: Adjustment.kinds())
    field(:note_body, :string, virtual: true)
    field(:title, :string)

    belongs_to(:disruption, Disruption)
    has_many(:days_of_week, DayOfWeek, on_replace: :delete)
    has_many(:exceptions, Exception, on_replace: :delete)
    has_many(:trip_short_names, TripShortName, on_replace: :delete)

    many_to_many(:adjustments, Adjustment,
      join_through: "disruption_adjustments",
      on_replace: :delete
    )

    timestamps(type: :utc_datetime)
  end

  @required_fields [:start_date, :end_date, :row_approved, :description, :title]
  @permitted_fields @required_fields ++ [:adjustment_kind, :note_body]

  @doc """
  Returns a list of either the revision's `adjustment_kind` if it has one, or the distinct kinds
  of its `adjustments`.
  """
  @spec adjustment_kinds(t()) :: [atom()]
  def adjustment_kinds(%__MODULE__{adjustment_kind: kind}) when not is_nil(kind), do: [kind]

  def adjustment_kinds(%__MODULE__{adjustments: adjustments}) when is_list(adjustments),
    do: adjustments |> Enum.map(&Adjustment.kind/1) |> Enum.uniq()

  @spec associations() :: [atom()]
  def associations, do: ~w(adjustments days_of_week exceptions trip_short_names)a

  @doc "Gets a revision by ID with preloaded associations."
  @spec get!(id()) :: t()
  def get!(id), do: __MODULE__ |> Repo.get!(id) |> Repo.preload(associations())

  @spec changeset(t() | Changeset.t(t()), map) :: Changeset.t(t())
  def changeset(data, attrs) do
    data
    |> Changeset.cast(attrs, @permitted_fields)
    |> cast_adjustments(attrs)
    |> Changeset.cast_assoc(:days_of_week,
      with: &DayOfWeek.changeset/2,
      required: true,
      required_message: "must be selected"
    )
    |> Changeset.cast_assoc(:exceptions, with: &Exception.changeset/2)
    |> Changeset.cast_assoc(:trip_short_names, with: &TripShortName.changeset/2)
    |> Changeset.validate_required(@required_fields)
    |> Changeset.validate_length(:days_of_week, min: 1)
    |> Changeset.validate_length(:title, min: 1, max: 40)
    |> validate_adjustments_or_adjustment_kind()
    |> validate_days_of_week_between_start_and_end_date()
    |> validate_exceptions_are_applicable()
    |> validate_exceptions_are_unique()
    |> validate_exceptions_between_start_and_end_date()
    |> validate_start_date_before_end_date()
  end

  @doc """
  Creates a changeset for a new revision with changes mirroring the fields and associations of an
  existing revision.
  """
  @spec clone(t()) :: Changeset.t(t())
  def clone(%__MODULE__{adjustments: adjustments} = revision) do
    Changeset.change(
      %__MODULE__{},
      revision
      |> clone_fields()
      |> Map.merge(%{adjustments: adjustments})
      |> Map.merge(
        ~w(days_of_week exceptions trip_short_names)a
        |> Enum.map(fn assoc -> {assoc, Enum.map(Map.get(revision, assoc), &clone_fields/1)} end)
        |> Enum.into(%{})
      )
    )
  end

  @doc """
  Constructs a new revision with the given attributes. Compared to `%DisruptionRevision{...}`,
  sets all associations to `[]` instead of `%Ecto.Association.NotLoaded{}`, so code that expects
  a fully-preloaded revision will work.
  """
  @spec new(Enum.t()) :: t()
  def new(attrs \\ %{}) do
    %__MODULE__{adjustments: [], days_of_week: [], exceptions: [], trip_short_names: []}
    |> struct!(attrs)
  end

  @spec publish!([integer()]) :: :ok
  def publish!(ids) do
    Repo.transaction(fn ->
      # Update disruptions only where the published revision is changing
      from(d in Disruption,
        join: dr in assoc(d, :revisions),
        where: dr.id in ^ids,
        where: dr.id != d.published_revision_id or is_nil(d.published_revision_id),
        update: [set: [published_revision_id: dr.id, last_published_at: fragment("now()")]]
      )
      |> Repo.update_all([])

      # since GTFS creator doesn't know about deleted disruptions, consider any currently
      # deleted disruptions part of this publishing notice.
      :ok = publish_deleted!()
    end)

    :ok
  end

  # For `many_to_many` associations, `cast_assoc` only supports creating/updating/deleting the
  # records in the target table (adjustments), not the records in the join table, so we have to
  # implement this cast ourselves
  defp cast_adjustments(data, %{"adjustments" => attrs}) do
    ids = attrs |> Map.get("id", []) |> Enum.reject(&(&1 in [nil, ""]))
    adjustments = Repo.all(from a in Adjustment, where: a.id in ^ids)
    Changeset.put_assoc(data, :adjustments, adjustments)
  end

  defp cast_adjustments(data, _), do: data

  defp clone_fields(%module{} = record) do
    Map.take(
      record,
      module.__schema__(:fields) -- ~w(id disruption_revision_id inserted_at updated_at)a
    )
  end

  @spec publish_deleted!() :: :ok
  defp publish_deleted! do
    from(
      [disruptions: d, revisions: r] in Disruption.with_latest_revisions(),
      where: r.is_active == false,
      where: is_nil(d.published_revision_id) or d.published_revision_id != r.id,
      update: [set: [published_revision_id: r.id, last_published_at: fragment("now()")]]
    )
    |> Repo.update_all([])

    :ok
  end

  defp validate_adjustments_or_adjustment_kind(changeset) do
    kind = Changeset.get_field(changeset, :adjustment_kind)
    adjustments = Changeset.get_field(changeset, :adjustments)

    cond do
      adjustments == [] ->
        Changeset.validate_required(changeset, :adjustment_kind,
          message: "is required without adjustments"
        )

      adjustments != [] and kind not in [nil, ""] ->
        Changeset.add_error(changeset, :adjustment_kind, "cannot be set with adjustments")

      true ->
        changeset
    end
  end

  @spec validate_days_of_week_between_start_and_end_date(Changeset.t(t())) :: Changeset.t(t())
  defp validate_days_of_week_between_start_and_end_date(changeset) do
    start_date = Changeset.get_field(changeset, :start_date)
    end_date = Changeset.get_field(changeset, :end_date)
    days_of_week = Changeset.get_field(changeset, :days_of_week, [])

    cond do
      is_nil(start_date) or is_nil(end_date) ->
        changeset

      Date.diff(end_date, start_date) >= 6 ->
        changeset

      Enum.all?(days_of_week, fn day ->
        Enum.member?(
          Enum.map(date_range(start_date, end_date), fn date -> Date.day_of_week(date) end),
          DayOfWeek.day_number(day)
        )
      end) ->
        changeset

      true ->
        Changeset.add_error(changeset, :days_of_week, "should fall between start and end dates")
    end
  end

  @spec validate_exceptions_are_applicable(Changeset.t(t())) :: Changeset.t(t())
  defp validate_exceptions_are_applicable(changeset) do
    days_of_week = Changeset.get_field(changeset, :days_of_week, [])
    exceptions = Changeset.get_field(changeset, :exceptions, [])

    day_of_week_numbers = Enum.map(days_of_week, fn x -> DayOfWeek.day_number(x) end)

    if Enum.all?(exceptions, fn exception ->
         Enum.member?(day_of_week_numbers, Date.day_of_week(exception.excluded_date))
       end) do
      changeset
    else
      Changeset.add_error(changeset, :exceptions, "should be applicable to days of week")
    end
  end

  @spec validate_exceptions_are_unique(Changeset.t(t())) :: Changeset.t(t())
  defp validate_exceptions_are_unique(changeset) do
    exceptions = Changeset.get_field(changeset, :exceptions, [])

    if Enum.uniq_by(exceptions, & &1.excluded_date) == exceptions do
      changeset
    else
      Changeset.add_error(changeset, :exceptions, "should be unique")
    end
  end

  @spec validate_exceptions_between_start_and_end_date(Changeset.t(t())) :: Changeset.t(t())
  defp validate_exceptions_between_start_and_end_date(changeset) do
    start_date = Changeset.get_field(changeset, :start_date)
    end_date = Changeset.get_field(changeset, :end_date)
    exceptions = Changeset.get_field(changeset, :exceptions, [])

    cond do
      is_nil(start_date) or is_nil(end_date) ->
        changeset

      Enum.all?(exceptions, fn exception ->
        Enum.member?([:lt, :eq], Date.compare(start_date, exception.excluded_date)) and
            Enum.member?([:gt, :eq], Date.compare(end_date, exception.excluded_date))
      end) ->
        changeset

      true ->
        Changeset.add_error(changeset, :exceptions, "should fall between start and end dates")
    end
  end

  @spec validate_start_date_before_end_date(Changeset.t(t())) :: Changeset.t(t())
  defp validate_start_date_before_end_date(changeset) do
    start_date = Changeset.get_field(changeset, :start_date)
    end_date = Changeset.get_field(changeset, :end_date)

    cond do
      is_nil(start_date) or is_nil(end_date) ->
        changeset

      Date.compare(start_date, end_date) == :gt ->
        Changeset.add_error(changeset, :start_date, "can't be after end date")

      true ->
        changeset
    end
  end

  defp date_range(start_date, end_date) do
    if Date.compare(start_date, end_date) == :gt do
      Date.range(start_date, end_date, -1)
    else
      Date.range(start_date, end_date)
    end
  end
end
