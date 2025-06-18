defmodule Arrow.AuthTokenTest do
  use Arrow.DataCase

  alias Arrow.AuthToken
  alias Arrow.Repo

  describe "database" do
    test "can insert a token" do
      auth_token = %AuthToken{
        username: "foo@mbta.com",
        token: "bar"
      }

      assert {:ok, new_auth_token} = Repo.insert(auth_token)
      assert new_auth_token.username == auth_token.username
      assert new_auth_token.token == auth_token.token

      assert new_auth_token in Repo.all(AuthToken)
    end

    test "username is unique" do
      auth_token_1 = %AuthToken{
        username: "foo@mbta.com",
        token: "bar"
      }

      auth_token_2 = %AuthToken{
        username: "foo@mbta.com",
        token: "baz"
      }

      assert {:ok, _} = Repo.insert(auth_token_1)
      assert {:error, _} = Repo.insert(AuthToken.changeset(auth_token_2, %{}))
    end
  end

  describe "get_or_create_token_for_user/1" do
    test "retrieves existing token" do
      auth_token = %AuthToken{
        username: "foo@mbta.com",
        token: "bar"
      }

      {:ok, _} = Repo.insert(auth_token)

      assert AuthToken.get_or_create_token_for_user("foo@mbta.com") == "bar"
    end

    test "creates new token" do
      assert "foo@mbta.com" |> AuthToken.get_or_create_token_for_user() |> String.length() == 32
    end
  end
end
