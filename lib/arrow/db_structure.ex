defmodule Arrow.DBStructure.Table do
  @type t :: %__MODULE__{
          name: String.t(),
          columns: [atom()],
          optional_fkeys: [atom()]
        }
  defstruct [:name, columns: [], optional_fkeys: []]
end

defmodule Arrow.DBStructure do
  import Ecto.Query
  alias Arrow.DBStructure.Table

  @temp_table "temp_join_table"
  @type db_structure :: [Table.t()]

  @spec structure :: db_structure
  def structure do
    [
      %Table{
        name: "adjustments",
        columns: [:id, :route_id, :source, :source_label, :inserted_at, :updated_at]
      },
      %Table{
        name: "disruptions",
        columns: [
          :id,
          :inserted_at,
          :updated_at,
          :last_published_at
        ],
        optional_fkeys: [:ready_revision_id, :published_revision_id]
      },
      %Table{
        name: "disruption_revisions",
        columns: [
          :id,
          :start_date,
          :end_date,
          :is_active,
          :disruption_id,
          :inserted_at,
          :updated_at
        ]
      },
      %Table{
        name: "disruption_adjustments",
        columns: [
          :id,
          :disruption_revision_id,
          :adjustment_id
        ]
      },
      %Table{
        name: "disruption_day_of_weeks",
        columns: [
          :id,
          :disruption_revision_id,
          :day_name,
          :start_time,
          :end_time,
          :inserted_at,
          :updated_at
        ]
      },
      %Table{
        name: "disruption_exceptions",
        columns: [
          :id,
          :disruption_revision_id,
          :excluded_date,
          :inserted_at,
          :updated_at
        ]
      },
      %Table{
        name: "disruption_trip_short_names",
        columns: [
          :id,
          :disruption_revision_id,
          :trip_short_name,
          :inserted_at,
          :updated_at
        ]
      }
    ]
  end

  @spec dump_data(db_structure) :: %{}
  def dump_data(structure \\ structure()) do
    Map.new(structure, fn table ->
      columns_to_select = table.columns ++ table.optional_fkeys
      {table.name, table.name |> from(select: ^columns_to_select) |> Arrow.Repo.all()}
    end)
  end

  @spec load_data(Ecto.Repo.t(), %{}, db_structure) :: :ok
  def load_data(repo, data, structure \\ structure()) do
    repo.transaction(fn ->
      # null out optional fkeys
      structure
      |> Enum.each(fn table ->
        Enum.each(table.optional_fkeys, fn column ->
          set = Keyword.new([{column, nil}])
          table.name |> from(update: [set: ^set]) |> repo.update_all([])
        end)
      end)

      # delete all rows
      structure
      |> Enum.reverse()
      |> Enum.each(fn table ->
        {_num_deleted, _return} = table.name |> from() |> repo.delete_all()
      end)

      # add back in rows, exclude optional fkeys

      Enum.each(structure, fn table ->
        columns_to_include = table.columns

        repo.insert_all(
          table.name,
          data |> Map.get(table.name) |> Enum.map(&Map.take(&1, columns_to_include))
        )
      end)

      # add back optional fkeys
      %{num_rows: _, rows: _} =
        Ecto.Adapters.SQL.query!(
          repo,
          "CREATE TEMP TABLE " <> @temp_table <> " (table_id INT, fkey_value INT)",
          []
        )

      Enum.each(structure, fn table ->
        Enum.each(table.optional_fkeys, fn fkey_column ->
          @temp_table |> from() |> repo.delete_all()

          temp_rows =
            data
            |> Map.get(table.name)
            |> Enum.map(&%{table_id: Map.get(&1, :id), fkey_value: Map.get(&1, fkey_column)})
            |> Enum.filter(&(!is_nil(&1[:fkey_value])))

          {_num_inserted, _return} = repo.insert_all(@temp_table, temp_rows)

          from(t in table.name,
            join: j in @temp_table,
            on: t.id == j.table_id,
            update: [
              set: [{^fkey_column, field(j, :fkey_value)}]
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
