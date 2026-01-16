defmodule Arrow.Schema do
  @moduledoc """
  Arrow specific options for Ecto.Schema
  """

  defmacro __using__(_opts) do
    quote do
      use TypedEctoSchema
    end
  end
end
