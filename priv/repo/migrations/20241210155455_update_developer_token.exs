defmodule Arrow.Repo.Migrations.UpdateDeveloperToken do
  use Ecto.Migration

  def up do
    execute "UPDATE auth_tokens SET username = 'developer@mbta.com' WHERE username = 'ActiveDirectory_MBTA\\developer'"
  end

  def down do
    execute "UPDATE auth_tokens SET username = 'ActiveDirectory_MBTA\\developer' WHERE username = 'developer@mbta.com'"
  end
end
