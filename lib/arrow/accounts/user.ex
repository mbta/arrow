defmodule Arrow.Accounts.User do
  @moduledoc """
  A module for Arrow user accounts.
  """

  @type group() :: :admin

  @type t() :: %__MODULE__{
          id: String.t(),
          groups: MapSet.t(group())
        }

  @enforce_keys [:id]
  defstruct @enforce_keys ++ [groups: MapSet.new()]
end
