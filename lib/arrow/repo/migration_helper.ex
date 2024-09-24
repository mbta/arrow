defmodule Arrow.Repo.MigrationHelper do
  @moduledoc """
  Conveniences for migrations.

  Currently these functions are used only in the gtfs_* table migrations.
  """

  import Ecto.Migration

  @spec create_and_populate_enum_table(
          String.t(),
          Enumerable.t(String.t()) | Enumerable.t({integer, String.t()})
        ) :: term
  @doc ~S'''
  Convenience function to create small (id, name) tables whose rows are all known at time of migration.

  Usage:

      create_and_populate_enum_table("gtfs_route_types", ["Light Rail", "Heavy Rail"])

  does the following:

      create table("gtfs_route_types", primary_key: [name: :id, type: :integer]) do
        add :name, :string, null: false
      end

      create unique_index("gtfs_route_types", [:name])

      up_fn = fn ->
        repo().query!("""
        INSERT INTO "gtfs_route_types" ("id", "name") VALUES
          (0, 'Light Rail'),
          (1, 'Heavy Rail')
        """)
      end

      execute(up_fn, fn -> nil end)

  You can also pass a map or a list of `{index, value}` pairs in cases where IDs
  are not sequential and/or 0-indexed:

      create_and_populate_enum_table("coolness_level", %{0 => "lame", 5 => "mid", 10 => "cool", 11 => "rad"})
  '''
  def create_and_populate_enum_table(name, values) when is_binary(name) do
    values = normalize_values!(values)

    values_fragment =
      values
      |> normalize_values!()
      |> Enum.map_join(",\n  ", fn {i, value} -> "(#{i}, '#{value}')" end)

    create table(name) do
      add(:name, :string, null: false)
    end

    create(unique_index(name, [:name]))

    up_fn = fn ->
      repo().query!("""
      INSERT INTO "#{name}" ("id", "name") VALUES
        #{values_fragment}
      """)
    end

    execute(up_fn, fn -> nil end)
  end

  @doc """
  Creates a table using Ecto.Migration's standard `create/1` function, and then
  sets all of its foreign key, unique, and exclusion constraints to DEFERRABLE
  INITIALLY IMMEDIATE.
  """
  def create_deferrable(%Ecto.Migration.Table{name: name} = table) do
    create(table)
    execute_make_deferrable(name)
  end

  def create_deferrable(obj) do
    raise "create_deferrable can only be used to create tables, got: #{inspect(obj)}"
  end

  @doc """
  Creates a table using Ecto.Migration's standard `create/2` macro, and then
  sets all of its foreign key, unique, and exclusion constraints to DEFERRABLE
  INITIALLY IMMEDIATE.
  """
  defmacro create_deferrable(object_ast, opts_ast) do
    table =
      case object_ast do
        {:table, _meta, [table | _]} when is_binary(table) ->
          table

        _ ->
          raise "create_deferrable can only be used to create tables, " <>
                  "got: `#{Macro.to_string(object_ast)}`"
      end

    quote do
      create(unquote(object_ast), unquote(opts_ast))
      unquote(__MODULE__).execute_make_deferrable(unquote(Macro.escape(table)))
    end
  end

  @doc """
  Sets all foreign key, primary key, unique, and exclusion constraints
  on the given table to be DEFERRABLE INITIALLY IMMEDIATE.
  """
  def execute_make_deferrable(table) do
    execute(
      fn -> make_constraints_deferrable(table) end,
      fn -> nil end
    )
  end

  defp make_constraints_deferrable(table_name) do
    # Constraints that can be deferred:
    # 'f': foreign key
    # 'p': primary key (We don't defer these, though)
    # 'u': unique
    # 'x': exclusion
    #
    # We skip primary keys because while they do support DEFERRABLE, you can't
    # create an FK constraint on a column with a deferrable PK constraint. From docs:
    # > The referenced columns must be the columns of a non-deferrable unique
    # > or primary key constraint in the referenced table.
    query = """
    SELECT pgc.conname, pgc.contype, pg_get_constraintdef(pgc.oid, true)
    FROM pg_catalog.pg_constraint pgc
    -- Skip 'p'. We won't make primary key constraints deferrable.
    WHERE pgc.contype IN ('f', 'u', 'x')
      AND pgc.conrelid = '#{table_name}'::regclass
    """

    %{rows: constraints} = repo().query!(query, [], log: false)
    Enum.each(constraints, &make_constraint_deferrable(table_name, &1))
  end

  # Foreign key constraint can be altered.
  defp make_constraint_deferrable(table, [constraint, "f", _definition]) do
    repo().query!("""
    ALTER TABLE "#{table}"
      ALTER CONSTRAINT "#{constraint}" DEFERRABLE INITIALLY IMMEDIATE
    """)
  end

  # All other constraints must be dropped and recreated.
  defp make_constraint_deferrable(table, [constraint, type, definition]) when type in ~w[p u x] do
    repo().query!("""
    ALTER TABLE "#{table}"
    DROP CONSTRAINT "#{constraint}"
    """)

    repo().query!("""
    ALTER TABLE "#{table}"
      ADD CONSTRAINT "#{constraint}" #{definition} DEFERRABLE INITIALLY IMMEDIATE
    """)
  end

  defp normalize_values!([_ | _] = values) do
    all_strings? = Enum.all?(values, &String.valid?/1)
    all_indexed_strings? = Enum.all?(values, &indexed_value?/1)

    unless all_strings? or all_indexed_strings? do
      raise "`values` must be a homogeneous list of either strings or {integer, string} tuples"
    end

    if all_indexed_strings? do
      values
    else
      Enum.with_index(values, fn v, i -> {i, v} end)
    end
  end

  defp normalize_values!(%{} = values) when map_size(values) > 0 do
    unless Enum.all?(values, &indexed_value?/1) do
      raise "`values` must have integer keys and string values"
    end

    Enum.to_list(values)
  end

  defp normalize_values!(_) do
    raise "`values` must be a nonempty list or map"
  end

  defp indexed_value?({i, value}) do
    is_integer(i) and String.valid?(value)
  end

  defp indexed_value?(_), do: false
end
