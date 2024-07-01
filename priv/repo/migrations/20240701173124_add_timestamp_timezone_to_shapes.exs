defmodule Arrow.Repo.Migrations.AddTimestampTimezoneToShapes do
  use Ecto.Migration

  def up do
    alter table(:shapes) do
      modify :inserted_at, :timestamptz
      modify :updated_at, :timestamptz
    end
  end
end
