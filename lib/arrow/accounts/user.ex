defmodule Arrow.Accounts.User do
  @moduledoc """
  A module for Arrow user accounts.
  """

  @type role() :: String.t()

  @type t() :: %__MODULE__{
          id: String.t(),
          roles: MapSet.t(role())
        }

  @enforce_keys [:id]
  defstruct @enforce_keys ++ [roles: MapSet.new()]
end
