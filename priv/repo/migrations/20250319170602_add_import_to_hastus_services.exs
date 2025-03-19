defmodule Arrow.Repo.Migrations.AddImportToHastusServices do
  use Ecto.Migration

  def change do
    alter table(:hastus_services) do
      add :should_import, :boolean, null: false, default: true
    end
  end
end
