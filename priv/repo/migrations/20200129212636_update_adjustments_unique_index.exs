defmodule Arrow.Repo.Migrations.UpdateAdjustmentsUniqueIndex do
  use Ecto.Migration

  def change do
    drop index(:adjustments, [:source, :source_label], name: :adjustments_source_source_label)

    create unique_index(:adjustments, [:source_label])
  end
end
