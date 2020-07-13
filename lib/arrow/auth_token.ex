defmodule Arrow.AuthToken do
  @moduledoc """
  AuthToken: a per-user token used to authenticate to the Arrow API.

  Primarily used by gtfs_creator to fetch disruption information.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          username: String.t(),
          token: String.t()
        }

  schema "auth_tokens" do
    field :username, :string
    field :token, :string
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(auth_token, attrs) do
    auth_token
    |> cast(attrs, [:username, :token])
    |> validate_required([:username, :token])
    |> unique_constraint(:username)
  end

  @doc """
  Given a username, either retrieves the existing token for that user
  or creates and inserts a new one.
  """
  @spec get_or_create_token_for_user(String.t()) :: String.t()
  def get_or_create_token_for_user(username) do
    auth_token = Arrow.Repo.get_by(__MODULE__, username: username)

    case auth_token do
      %__MODULE__{token: token} ->
        token

      nil ->
        token = :crypto.strong_rand_bytes(16) |> Base.encode16() |> String.downcase()

        auth_token = %__MODULE__{
          username: username,
          token: token
        }

        {:ok, _auth_token} = Arrow.Repo.insert(auth_token)

        token
    end
  end
end
