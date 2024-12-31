defmodule Arrow.Repo.Migrations.AddCiReadonlyUserToken do
  use Ecto.Migration

  def change do
    Arrow.AuthToken.get_or_create_token_for_user("gtfs_creator_ci@mbta.com")
  end
end
