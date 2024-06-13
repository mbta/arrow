defmodule Arrow.Repo.Migrations.AddTitleToDisruptions do
  use Ecto.Migration
  import Ecto.Query

  def up do
    alter table(:disruption_revisions) do
      add :title, :string, size: 40
    end

    flush()

    from(d in Arrow.DisruptionRevision,
      update: [set: [title: fragment("substring(?, 1, 40)", d.description)]]
    )
    |> Arrow.Repo.update_all([])

    alter table(:disruption_revisions) do
      modify :title, :string, size: 40, null: false
    end
  end

  def down do
    alter table(:disruption_revisions) do
      remove :title
    end
  end
end
