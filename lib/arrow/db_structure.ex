defmodule Arrow.DBStructure do
  import Ecto.Query

  @temp_table "temp_join_table"
  @type db_structure :: [{String.t(), [atom() | {atom(), atom()}]}]

  @spec structure :: db_structure
  def structure do
    [
      {"adjustments", [:id, :route_id, :source, :source_label, :inserted_at, :updated_at]},
      {"disruptions",
       [
         :id,
         {:ready_revision_id, :optional_fkey},
         {:published_revision_id, :optional_fkey},
         :inserted_at,
         :updated_at,
         :last_published_at
       ]},
      {"disruption_revisions",
       [
         :id,
         :start_date,
         :end_date,
         :is_active,
         :disruption_id,
         :inserted_at,
         :updated_at
       ]},
      {"disruption_adjustments",
       [
         :id,
         :disruption_revision_id,
         :adjustment_id
       ]},
      {"disruption_day_of_weeks",
       [
         :id,
         :disruption_revision_id,
         :day_name,
         :start_time,
         :end_time,
         :inserted_at,
         :updated_at
       ]},
      {"disruption_exceptions",
       [
         :id,
         :disruption_revision_id,
         :excluded_date,
         :inserted_at,
         :updated_at
       ]},
      {"disruption_trip_short_names",
       [
         :id,
         :disruption_revision_id,
         :trip_short_name,
         :inserted_at,
         :updated_at
       ]}
    ]
  end

  @spec dump_data(db_structure) :: %{}
  def dump_data(structure \\ structure()) do
    Map.new(structure, fn {table, columns} ->
      columns_to_select =
        Enum.map(columns, fn c ->
          case c do
            {column_name, _} -> column_name
            column_name -> column_name
          end
        end)

      {table, table |> from(select: ^columns_to_select) |> Arrow.Repo.all()}
    end)
  end

  @spec load_data(Ecto.Repo.t(), %{}, db_structure) :: :ok
  def load_data(repo, data, structure \\ structure()) do
    repo.transaction(fn ->
      # null out optional fkeys
      structure
      |> Enum.each(fn {table, columns} ->
        Enum.each(columns, fn column ->
          case column do
            {name, :optional_fkey} ->
              set = Keyword.new([{name, nil}])
              table |> from(update: [set: ^set]) |> repo.update_all([])

            _ ->
              nil
          end
        end)
      end)

      # delete all rows
      structure
      |> Enum.reverse()
      |> Enum.each(fn {table, _columns} ->
        {_num_deleted, _return} = table |> from() |> repo.delete_all()
      end)

      # add back in rows, exclude optional fkeys

      Enum.each(structure, fn {table, columns} ->
        columns_to_include = Enum.filter(columns, &(!match?({_, :optional_fkey}, &1)))

        repo.insert_all(
          table,
          data |> Map.get(table) |> Enum.map(&Map.take(&1, columns_to_include))
        )
      end)

      # add back optional fkeys
      %{num_rows: _, rows: _} =
        Ecto.Adapters.SQL.query!(
          repo,
          "CREATE TEMP TABLE " <> @temp_table <> " (table_id INT, fkey_value INT)",
          []
        )

      Enum.each(data, fn {table, rows} ->
        columns_to_include =
          structure
          |> Map.new()
          |> Map.get(table)
          |> Enum.filter(&match?({_, :optional_fkey}, &1))
          |> Enum.map(&elem(&1, 0))

        @temp_table |> from() |> repo.delete_all()

        Enum.each(columns_to_include, fn column ->
          temp_rows =
            rows
            |> Enum.map(&%{table_id: Map.get(&1, :id), fkey_value: Map.get(&1, column)})
            |> Enum.filter(&(!is_nil(&1[:fkey_value])))

          {_num_inserted, _return} = repo.insert_all(@temp_table, temp_rows)

          from(t in table,
            join: j in @temp_table,
            on: t.id == j.table_id,
            update: [
              set: [{^column, field(j, :fkey_value)}]
            ]
          )
          |> repo.update_all([])

          @temp_table |> from() |> repo.delete_all()
        end)
      end)
    end)

    :ok
  end
end
