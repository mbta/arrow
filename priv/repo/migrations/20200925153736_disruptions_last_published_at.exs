defmodule Arrow.Repo.Migrations.DisruptionsLastPublishedAt do
  use Ecto.Migration

  def change do
    alter table(:disruptions) do
      add(:last_published_at, :timestamptz)
    end
  end
end
