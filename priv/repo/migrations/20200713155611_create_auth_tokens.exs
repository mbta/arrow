defmodule Arrow.Repo.Migrations.CreateAuthTokens do
  use Ecto.Migration

  def change do
    create table(:auth_tokens) do
      add :username, :text, null: false
      add :token, :text, null: false
    end

    create unique_index(:auth_tokens, [:username])

    create index(:auth_tokens, [:token])
  end
end
