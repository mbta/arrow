defmodule Arrow.Disruption do
  @moduledoc """
  Disruption: the configuration of trips to which one or more Adjustment(s) is applied.

  - Specific adjustment(s)
  - Dates and times
  - Trip short names (Commuter Rail only)
  """
  use Ecto.Schema
  import Ecto.Query

  alias Arrow.{DisruptionRevision, Repo}
  alias Ecto.Changeset

  @type id :: integer
  @type t :: %__MODULE__{
          id: id,
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

  @doc """
  Loads a single disruption by ID, with its latest revision preloaded, and all the revision's
  associations preloaded. Adjustments, exceptions, and trip short names are also sorted.
  """
  @spec get!(id) :: t
  def get!(id) do
    from(
      [disruptions: d, revisions: r] in with_latest_revisions(),
      where: d.id == ^id,
      left_join: a in assoc(r, :adjustments),
      left_join: days in assoc(r, :days_of_week),
      left_join: e in assoc(r, :exceptions),
      left_join: t in assoc(r, :trip_short_names),
      order_by: [a.source_label, e.excluded_date, t.trip_short_name],
      preload: [
        revisions: {r, [adjustments: a, days_of_week: days, exceptions: e, trip_short_names: t]}
      ]
    )
    |> Repo.one!()
  end

  @doc "Creates a new disruption, with its first revision having the given attributes."
  @spec create(map) :: {:ok, id} | {:error, Changeset.t(DisruptionRevision.t())}
  def create(attrs) do
    Repo.transaction(fn ->
      %{id: id} = Repo.insert!(%__MODULE__{})

      case DisruptionRevision.new(disruption_id: id)
           |> DisruptionRevision.changeset(attrs)
           |> Repo.insert() do
        {:ok, _revision} -> id
        {:error, changeset} -> Repo.rollback(changeset)
      end
    end)
  end

  @doc "Creates a new revision, with given attributes, of the given disruption ID."
  @spec update(id, map) :: {:ok, id} | {:error, Changeset.t(DisruptionRevision.t())}
  def update(id, attrs) do
    Repo.transaction(fn ->
      case id
           |> latest_revision_id()
           |> DisruptionRevision.clone!()
           |> DisruptionRevision.changeset(attrs)
           |> Repo.update() do
        {:ok, _revision} -> id
        {:error, changeset} -> Repo.rollback(changeset)
      end
    end)
  end

  @doc "Creates a new revision of the given disruption ID with `is_active` set to false."
  @spec delete!(id) :: DisruptionRevision.t()
  def delete!(id) do
    {:ok, new_revision} =
      Repo.transaction(fn ->
        id
        |> latest_revision_id()
        |> DisruptionRevision.clone!()
        |> Changeset.change(%{is_active: false})
        |> Repo.update!()
      end)

    new_revision
  end

  @spec latest_revision_id(id) :: DisruptionRevision.id()
  def latest_revision_id(id) do
    from(r in DisruptionRevision,
      where: r.disruption_id == ^id,
      select: max(r.id),
      group_by: r.disruption_id
    )
    |> Repo.one!()
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
end
