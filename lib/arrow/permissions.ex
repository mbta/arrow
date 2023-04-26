defmodule Arrow.Permissions do
  @moduledoc """
  The central authority for authorization requests.
  """
  alias Arrow.Accounts.User

  @required_groups Application.compile_env!(:arrow, :required_groups)

  @type action() ::
          :create_disruption
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
  for {action, required_groups} <- @required_groups do
    def authorize?(unquote(action), %User{groups: groups}) do
      matches_group(groups, unquote(required_groups))
    end
  end

  def authorize?(_, _), do: false

  @spec matches_group(list(User.group()), list(User.group())) :: boolean()
  defp matches_group(user_groups, required_groups) do
    Enum.any?(user_groups, &(&1 in required_groups))
  end
end
