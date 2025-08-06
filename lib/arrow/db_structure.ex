defmodule Arrow.DBStructure.Table do
  @moduledoc false

  @type t :: %__MODULE__{
          name: String.t(),
          columns: [atom()],
          optional_fkeys: [atom()],
          sequences: [{atom(), String.t()}]
        }
  defstruct [:name, columns: [], optional_fkeys: [], sequences: []]
end

defmodule Arrow.DBStructure do
  @moduledoc """
  Declarative description of our DB structure, so that it can be cloned locally
  from dev/prod, maintaining foreign key relationships.
  """

  import Ecto.Query

  alias Arrow.DBStructure.Table
  alias Ecto.Adapters.SQL

  @temp_table "temp_join_table"
  @type db_structure :: [Table.t()]

  @spec structure() :: db_structure()
  def structure do
    [
      %Table{
        name: "adjustments",
        columns: [:id, :route_id, :source, :source_label, :inserted_at, :updated_at],
        sequences: [{:id, "adjustments_id_seq"}]
      },
      %Table{
        name: "disruptions",
        columns: [
          :id,
          :inserted_at,
          :updated_at,
          :last_published_at
        ],
        optional_fkeys: [:published_revision_id],
        sequences: [{:id, "disruptions_id_seq1"}]
      },
      %Table{
        name: "disruption_revisions",
        columns: [
          :id,
          :start_date,
          :end_date,
          :description,
          :row_approved,
          :adjustment_kind,
          :is_active,
          :disruption_id,
          :inserted_at,
          :updated_at,
          :title
        ],
        sequences: [{:id, "disruptions_id_seq"}]
      },
      %Table{
        name: "disruption_adjustments",
        columns: [
          :id,
          :disruption_revision_id,
          :adjustment_id
        ],
        sequences: [{:id, "disruption_adjustments_id_seq"}]
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
        ],
        sequences: [{:id, "disruption_day_of_weeks_id_seq"}]
      },
      %Table{
        name: "disruption_exceptions",
        columns: [
          :id,
          :disruption_revision_id,
          :excluded_date,
          :inserted_at,
          :updated_at
        ],
        sequences: [{:id, "disruption_exceptions_id_seq"}]
      },
      %Table{
        name: "disruption_trip_short_names",
        columns: [
          :id,
          :disruption_revision_id,
          :trip_short_name,
          :inserted_at,
          :updated_at
        ],
        sequences: [{:id, "disruption_trip_short_names_id_seq"}]
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
      nullify_optional_fkeys(repo, structure)
      delete_all_rows(repo, structure)
      add_rows_excluding_optional_fkeys(repo, structure, data)
      add_optional_fkeys(repo, structure, data)

      # reset sequences to avoid ID collisions
      reset_sequences(repo, structure)
    end)

    :ok
  end

  defp nullify_optional_fkeys(repo, structure) do
    Enum.each(structure, fn table ->
      Enum.each(table.optional_fkeys, fn column ->
        set = Keyword.new([{column, nil}])
        table.name |> from(update: [set: ^set]) |> repo.update_all([])
      end)
    end)
  end

  defp delete_all_rows(repo, structure) do
    structure
    |> Enum.reverse()
    |> Enum.each(fn table ->
      {_num_deleted, _return} = table.name |> from() |> repo.delete_all()
    end)
  end

  defp add_rows_excluding_optional_fkeys(repo, structure, data) do
    Enum.each(structure, fn table ->
      columns_to_include = table.columns

      repo.insert_all(
        table.name,
        data |> Map.get(table.name) |> Enum.map(&Map.take(&1, columns_to_include))
      )
    end)
  end

  defp add_optional_fkeys(repo, structure, data) do
    %{num_rows: _, rows: _} =
      SQL.query!(
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

        repo.update_all(
          from(t in table.name,
            join: j in @temp_table,
            on: t.id == j.table_id,
            update: [set: [{^fkey_column, field(j, :fkey_value)}]]
          ),
          []
        )

        @temp_table |> from() |> repo.delete_all()
      end)
    end)
  end

  defp reset_sequences(repo, structure) do
    Enum.each(structure, fn table ->
      Enum.each(table.sequences, fn {seq_col, seq_name} ->
        max_id = repo.one(from(t in table.name, select: max(field(t, ^seq_col))))
        reset_sequence(repo, seq_name, max_id)
      end)
    end)
  end

  defp reset_sequence(_repo, _seq_name, nil) do
    nil
  end

  defp reset_sequence(repo, seq_name, max_id) do
    SQL.query!(
      repo,
      "ALTER SEQUENCE #{seq_name} RESTART WITH #{max_id + 1}",
      []
    )
  end
end
