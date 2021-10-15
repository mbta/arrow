defmodule Arrow.Accounts.Group do
  @moduledoc """
  Functions for working with groups.
  """

  @admin_group Application.compile_env!(:arrow, :cognito_groups)
               |> Enum.find(&(elem(&1, 1) == :admin))
               |> elem(0)

  @spec admin() :: String.t()
  def admin, do: @admin_group
end
