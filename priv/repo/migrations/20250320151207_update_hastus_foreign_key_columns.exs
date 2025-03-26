defmodule Arrow.Repo.Migrations.UpdateHastusForeignKeyColumns do
  use Ecto.Migration

  def change do
    alter table(:hastus_exports) do
      modify :disruption_id, references(:disruptionsv2, on_delete: :delete_all),
        from: references(:disruptionsv2, on_delete: :nothing)
    end

    alter table(:hastus_services) do
      modify :export_id, references(:hastus_exports, on_delete: :delete_all),
        from: references(:hastus_exports, on_delete: :nothing)
    end

    alter table(:hastus_service_dates) do
      modify :service_id, references(:hastus_services, on_delete: :delete_all),
        from: references(:hastus_services, on_delete: :nothing)
    end
  end
end
