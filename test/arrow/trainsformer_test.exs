defmodule Arrow.TrainsformerTest do
  use Arrow.DataCase

  alias Arrow.Trainsformer

  describe "trainsformer_exports" do
    alias Arrow.Trainsformer.Export

    import Arrow.TrainsformerFixtures

    @invalid_attrs %{s3_path: nil}

    test "list_trainsformer_exports/0 returns all trainsformer_exports" do
      export = export_fixture()
      assert Trainsformer.list_trainsformer_exports() == [export]
    end

    test "get_export!/1 returns the export with given id" do
      export = export_fixture()
      assert Trainsformer.get_export!(export.id) == export
    end

    test "create_export/1 with valid data creates a export" do
      valid_attrs = %{s3_path: "foo"}

      assert {:ok, %Export{} = export} = Trainsformer.create_export(valid_attrs)

      assert %{s3_path: "foo"} = export
    end

    test "create_export/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Trainsformer.create_export(@invalid_attrs)
    end

    test "update_export/2 with valid data updates the export" do
      export = export_fixture()
      update_attrs = %{}

      assert {:ok, %Export{}} = Trainsformer.update_export(export, update_attrs)
    end

    test "update_export/2 with invalid data returns error changeset" do
      export = export_fixture()
      assert {:error, %Ecto.Changeset{}} = Trainsformer.update_export(export, @invalid_attrs)
      assert export == Trainsformer.get_export!(export.id)
    end

    test "delete_export/1 deletes the export" do
      export = export_fixture()
      assert {:ok, %Export{}} = Trainsformer.delete_export(export)
      assert_raise Ecto.NoResultsError, fn -> Trainsformer.get_export!(export.id) end
    end

    test "change_export/1 returns a export changeset" do
      export = export_fixture()
      assert %Ecto.Changeset{} = Trainsformer.change_export(export)
    end
  end
end
