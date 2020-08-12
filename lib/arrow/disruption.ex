defmodule Arrow.Disruption do
  @moduledoc """
  Defines an instance where one or more Adjustments will be, are currently, or previously were
  applied to the feed. The disruption data is stored in a sequence of associated insert-only
  DisruptionRevisions; updating or deleting a disruption is done by cloning the latest revision
  and inserting a modified version of it.
  """

  use Ecto.Schema

  alias Arrow.Disruption.Revision
  alias Arrow.Repo
  alias Ecto.Changeset

  @type t :: %__MODULE__{
          latest_revision: Revision.t() | Ecto.Association.NotLoaded.t() | nil,
          published_revision: Revision.t() | Ecto.Association.NotLoaded.t() | nil,
          disruption_revisions: [Revision.t()] | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  # View which dynamically adds a `latest_revision_id` column.
  schema "disruptions_with_latest_revisions" do
    belongs_to :latest_revision, Revision
    belongs_to :published_revision, Revision

    has_many :disruption_revisions, Revision

    timestamps(type: :utc_datetime)
  end

  def insert(revision_data) do
    Repo.transaction(fn ->
      disruption = Repo.insert!(%__MODULE__{})

      case Repo.insert(Changeset.change(revision_data, %{disruption: disruption})) do
        {:ok, revision} ->
          # TEMPORARY: Always publish each new revision
          Repo.update!(Changeset.change(disruption, %{published_revision: revision}))
          revision

        {:error, error} ->
          Repo.rollback(error)
      end
    end)
  end

  def update(revision_data) do
    # TODO
    Repo.update(revision_data)
  end

  def delete(revision_data) do
    # TODO
    Repo.delete(revision_data)
  end
end
