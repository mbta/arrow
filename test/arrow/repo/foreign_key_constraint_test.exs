defmodule Arrow.Repo.ForeignKeyConstraintTest do
  use Arrow.DataCase, async: true

  alias Arrow.Repo.ForeignKeyConstraint

  setup do
    # In short:
    # a.b_id -> b.id
    # a.c_id -> c.id
    # b.c_id -> c.id
    # c.a_id -> a.id
    # , some with additional parameters to check that they are preserved by `drop` + `add`.

    Repo.query!("""
    CREATE TABLE "a" (
      id bigint NOT NULL PRIMARY KEY,
      b_id bigint,
      c_id bigint
    )
    """)

    Repo.query!("""
    CREATE TABLE "b" (
      id bigint NOT NULL PRIMARY KEY,
      c_id bigint
    )
    """)

    Repo.query!("""
    CREATE TABLE "c" (
      id bigint NOT NULL PRIMARY KEY,
      a_id bigint
    )
    """)

    Repo.query!("""
    ALTER TABLE "a"
      ADD CONSTRAINT "a_b_id_fkey" FOREIGN KEY (b_id) REFERENCES "b"(id),
      ADD CONSTRAINT "a_c_id_fkey" FOREIGN KEY (c_id) REFERENCES "c"(id) ON DELETE CASCADE DEFERRABLE INITIALLY IMMEDIATE
    """)

    Repo.query!("""
    ALTER TABLE "b"
      ADD CONSTRAINT "b_c_id_fkey" FOREIGN KEY (c_id) REFERENCES "c"(id)
    """)

    Repo.query!("""
    ALTER TABLE "c"
      ADD CONSTRAINT "c_a_id_fkey" FOREIGN KEY (a_id) REFERENCES "a"(id) DEFERRABLE INITIALLY DEFERRED
    """)

    :ok
  end

  describe "external_constraints_referencing_tables/1" do
    test "returns fkeys referencing one of the given tables from an external table" do
      assert fkeys = ForeignKeyConstraint.external_constraints_referencing_tables(["b", "c"])
      assert length(fkeys) == 2
      [fkey1, fkey2] = Enum.sort_by(fkeys, & &1.name)

      assert %ForeignKeyConstraint{name: "a_b_id_fkey", origin_table: "a", referenced_table: "b"} =
               fkey1

      assert %ForeignKeyConstraint{name: "a_c_id_fkey", origin_table: "a", referenced_table: "c"} =
               fkey2

      assert fkey1.definition == "FOREIGN KEY (b_id) REFERENCES b(id)"

      # "INITIALLY IMMEDIATE" is missing because it's the default DEFERRABLE behavior when not specified.
      assert fkey2.definition ==
               "FOREIGN KEY (c_id) REFERENCES c(id) ON DELETE CASCADE DEFERRABLE"

      assert [fkey] = ForeignKeyConstraint.external_constraints_referencing_tables(["a"])

      assert %ForeignKeyConstraint{name: "c_a_id_fkey", origin_table: "c", referenced_table: "a"} =
               fkey

      assert fkey.definition ==
               "FOREIGN KEY (a_id) REFERENCES a(id) DEFERRABLE INITIALLY DEFERRED"
    end
  end

  describe "drop/1" do
    test "drops the given fkey" do
      assert [c_a_fkey] = ForeignKeyConstraint.external_constraints_referencing_tables(["a"])

      Repo.transaction(fn ->
        assert :ok = ForeignKeyConstraint.drop(c_a_fkey)
      end)

      assert [] = ForeignKeyConstraint.external_constraints_referencing_tables(["a"])

      assert "c_a_id_fkey" not in Repo.all(
               from fk in Arrow.Repo.ForeignKeyConstraint, select: fk.name
             )
    end
  end

  describe "add/1" do
    test "adds the given previously-dropped fkey, preserving all parameters" do
      q = from fk in Arrow.Repo.ForeignKeyConstraint, where: fk.name == "a_c_id_fkey"
      fkey = Repo.one!(q)

      Repo.transaction(fn ->
        assert :ok = ForeignKeyConstraint.drop(fkey)
        assert :ok = ForeignKeyConstraint.add(fkey)
      end)

      assert %ForeignKeyConstraint{
               name: "a_c_id_fkey",
               origin_table: "a",
               referenced_table: "c",
               definition: "FOREIGN KEY (c_id) REFERENCES c(id) ON DELETE CASCADE DEFERRABLE"
             } = Repo.one!(q)

      q = from fk in Arrow.Repo.ForeignKeyConstraint, where: fk.name == "c_a_id_fkey"
      fkey = Repo.one!(q)

      Repo.transaction(fn ->
        assert :ok = ForeignKeyConstraint.drop(fkey)
        assert :ok = ForeignKeyConstraint.add(fkey)
      end)

      assert %ForeignKeyConstraint{
               name: "c_a_id_fkey",
               origin_table: "c",
               referenced_table: "a",
               definition: "FOREIGN KEY (a_id) REFERENCES a(id) DEFERRABLE INITIALLY DEFERRED"
             } = Repo.one!(q)
    end
  end
end
