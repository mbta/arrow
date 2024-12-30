defmodule Arrow.Repo.ForeignKeyConstraint do
  @moduledoc """
  Schema allowing Arrow to introspect its DB's foreign key constraints.
  """
  use Ecto.Schema
  import Ecto.Query
  alias Arrow.Repo

  @type t :: %__MODULE__{
          name: String.t(),
          origin_table: String.t(),
          referenced_table: String.t(),
          definition: String.t()
        }

  @primary_key false

  schema "foreign_key_constraints" do
    field :name
    field :origin_table
    field :referenced_table
    field :definition
  end

  @doc """
  Returns foreign key constraints that reference any table in `tables`,
  and originate in any table _not_ in `tables`.

  For example, given the following foreign key relations:

      foo.bar_id -> bar.id
      foo.baz_id -> baz.id
      baz.bar_id -> bar.id

  Calling this:

      external_constraints_referencing_tables(["bar", "baz"])

  Would produce this:

      [
        %ForeignKeyConstraint{origin_table: "foo", referenced_table: "bar"},
        %ForeignKeyConstraint{origin_table: "foo", referenced_table: "baz"},
      ]
  """
  @spec external_constraints_referencing_tables(list(String.t() | atom)) :: list(t())
  def external_constraints_referencing_tables(tables) when is_list(tables) do
    from(fk in __MODULE__,
      where: fk.referenced_table in ^tables,
      where: fk.origin_table not in ^tables
    )
    |> Repo.all()
  end

  @doc """
  Drops a foreign key constraint.

  This function should not be used to permanently drop a constraint--
  use Ecto's migration utilities to do that.
  """
  @spec drop(t()) :: :ok
  def drop(%__MODULE__{} = fk) do
    if Repo.in_transaction?() do
      _ =
        Repo.query!("""
        ALTER TABLE "#{fk.origin_table}"
          DROP CONSTRAINT "#{fk.name}"
        """)

      :ok
    else
      raise "must be in a transaction"
    end
  end

  @doc """
  Adds a foreign key constraint.

  This function should not be used to permanently add a new constraint--
  use Ecto's migration utilities to do that.

  This is intended only for re-adding a previously, temporarily dropped constraint.
  """
  @spec add(t()) :: :ok
  def add(%__MODULE__{} = fk) do
    if Repo.in_transaction?() do
      _ =
        Repo.query!("""
        ALTER TABLE "#{fk.origin_table}"
          ADD CONSTRAINT "#{fk.name}" #{fk.definition}
        """)

      :ok
    else
      raise "must be in a transaction"
    end
  end
end
