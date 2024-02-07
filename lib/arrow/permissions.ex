defmodule Arrow.Permissions do
  @moduledoc """
  The central authority for authorization requests.
  """
  alias Arrow.Accounts.User

  @required_roles Application.compile_env!(:arrow, :required_roles)

  @type action() ::
          :view_disruption
          | :create_disruption
          | :update_disruption
          | :delete_disruption
          | :view_change_feed

  @spec authorize(action(), User.t()) :: :ok | {:error, :unauthorized}
  def authorize(action, user) do
    if authorize?(action, user) do
      :ok
    else
      {:error, :unauthorized}
    end
  end

  @spec authorize?(action :: action(), user :: User.t()) :: boolean()
  for {action, required_roles} <- @required_roles do
    def authorize?(unquote(action), %User{roles: roles}) do
      matches_role(roles, unquote(required_roles))
    end
  end

  def authorize?(_, _), do: false

  @spec matches_role(list(User.role()), list(User.role())) :: boolean()
  defp matches_role(user_roles, required_roles) do
    Enum.any?(user_roles, &(&1 in required_roles))
  end
end
