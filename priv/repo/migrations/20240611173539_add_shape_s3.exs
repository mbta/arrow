defmodule Arrow.Repo.Migrations.AddShapeS3 do
  use Ecto.Migration

  def change do
    alter table("shapes") do
      add :bucket, :text
      add :path, :text
      add :prefix, :text
    end
  end
end
