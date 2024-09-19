defmodule Arrow.Gtfs.Schema do
  @moduledoc """
  Wrapper on Ecto.Schema that adds some helpers for the particularities
  of GTFS feed import.

  - Imports functions from `Arrow.Gtfs.ImportHelper`
  - Sets primary key to have name `:id` and type `:string`, and not autogenerate
  - Sets foreign key type to `:string`
  """

  defmacro __using__(_) do
    quote do
      import Arrow.Gtfs.ImportHelper
      use Ecto.Schema
      @primary_key {:id, :string, []}
      @foreign_key_type :string
    end
  end
end
