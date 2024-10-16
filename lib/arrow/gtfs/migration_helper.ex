defmodule Arrow.Gtfs.MigrationHelper do
  @moduledoc """
  Conveniences for GTFS table migrations.
  """
  import Ecto.Migration

  @doc """
  Creates a CHECK constraint asserting that an integer column's value
  is within a specified range.

  The following:

      create_int_code_constraint("some_table", :some_column, 1..3//1)

  adds a check that `some_column`'s value is between 1 and 3, inclusive.

  The following:

      create_int_code_constraint("some_table", :some_column, 5)

  adds a check that `some_column`'s value is between 0 and 5, inclusive.
  """
  @spec create_int_code_constraint(String.t(), atom, Range.t() | non_neg_integer) :: term
  def create_int_code_constraint(table, column, range_or_max)

  def create_int_code_constraint(table, column, first..last//1) do
    name = :"#{column}_must_be_in_range"
    create(constraint(table, name, check: check_expr(column, first, last)))
  end

  def create_int_code_constraint(table, column, max) when is_integer(max) and max >= 0 do
    create_int_code_constraint(table, column, 0..max//1)
  end

  defp check_expr(column, first, last) do
    "#{column} <@ int4range(#{first}, #{last}, '[]')"
  end

  @doc """
  Creates a Postgres enum type with the given allowed string values.
  """
  @spec create_enum_type(String.t(), list(String.t())) :: term
  def create_enum_type(name, strings) do
    values_list = Enum.map_join(strings, ",", &"'#{&1}'")

    execute(
      "CREATE TYPE #{name} AS ENUM (#{values_list})",
      "DROP TYPE #{name}"
    )
  end
end
