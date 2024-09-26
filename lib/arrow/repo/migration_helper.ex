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
