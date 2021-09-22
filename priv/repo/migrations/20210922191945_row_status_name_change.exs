defmodule Arrow.Repo.Migrations.RowStatusNameChange do
  use Ecto.Migration

  def change do
    rename table(:disruption_revisions), :row_confirmed, to: :row_approved
  end
end
