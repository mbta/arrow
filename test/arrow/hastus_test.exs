defmodule Arrow.HastusTest do
  use Arrow.DataCase

  alias Arrow.Hastus

  describe "exports" do
    import Arrow.HastusFixtures

    alias Arrow.Hastus.Export

    @invalid_attrs %{s3_path: nil}

    test "list_exports/0 returns all exports" do
      export = export_fixture()
      assert Hastus.list_exports() == [export]
    end

    test "get_export!/1 returns the export with given id" do
      export = export_fixture()
      assert Hastus.get_export!(export.id) == export
    end

    test "create_export/1 with valid data creates a export" do
      valid_attrs = %{s3_path: "some s3_path", services: [%{name: "some name"}]}

      assert {:ok, %Export{} = export} = Hastus.create_export(valid_attrs)
      assert export.s3_path == "some s3_path"
    end

    test "create_export/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Hastus.create_export(@invalid_attrs)
    end

    test "update_export/2 with valid data updates the export" do
      export = export_fixture()
      update_attrs = %{s3_path: "some updated s3_path"}

      assert {:ok, %Export{} = export} = Hastus.update_export(export, update_attrs)
      assert export.s3_path == "some updated s3_path"
    end

    test "update_export/2 with invalid data returns error changeset" do
      export = export_fixture()
      assert {:error, %Ecto.Changeset{}} = Hastus.update_export(export, @invalid_attrs)
      assert export == Hastus.get_export!(export.id)
    end

    test "delete_export/1 deletes the export" do
      export = export_fixture()
      assert {:ok, %Export{}} = Hastus.delete_export(export)
      assert_raise Ecto.NoResultsError, fn -> Hastus.get_export!(export.id) end
    end

    test "change_export/1 returns a export changeset" do
      export = export_fixture()
      assert %Ecto.Changeset{} = Hastus.change_export(export)
    end
  end

  describe "hastus_services" do
    import Arrow.HastusFixtures

    alias Arrow.Hastus.Service

    @invalid_attrs %{name: nil}

    test "list_hastus_services/0 returns all hastus_services" do
      service = service_fixture()
      assert Hastus.list_hastus_services() == [service]
    end

    test "get_service!/1 returns the service with given id" do
      service = service_fixture()
      assert Hastus.get_service!(service.id) == service
    end

    test "create_service/1 with valid data creates a service" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Service{} = service} = Hastus.create_service(valid_attrs)
      assert service.name == "some name"
    end

    test "create_service/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Hastus.create_service(@invalid_attrs)
    end

    test "update_service/2 with valid data updates the service" do
      service = service_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Service{} = service} = Hastus.update_service(service, update_attrs)
      assert service.name == "some updated name"
    end

    test "update_service/2 with invalid data returns error changeset" do
      service = service_fixture()
      assert {:error, %Ecto.Changeset{}} = Hastus.update_service(service, @invalid_attrs)
      assert service == Hastus.get_service!(service.id)
    end

    test "delete_service/1 deletes the service" do
      service = service_fixture()
      assert {:ok, %Service{}} = Hastus.delete_service(service)
      assert_raise Ecto.NoResultsError, fn -> Hastus.get_service!(service.id) end
    end

    test "change_service/1 returns a service changeset" do
      service = service_fixture()
      assert %Ecto.Changeset{} = Hastus.change_service(service)
    end
  end

  describe "hastus_service_dates" do
    import Arrow.HastusFixtures

    alias Arrow.Hastus.ServiceDate

    @invalid_attrs %{start_date: nil, end_date: nil}

    test "list_hastus_service_dates/0 returns all hastus_service_dates" do
      service_date = service_date_fixture()
      assert Hastus.list_hastus_service_dates() == [service_date]
    end

    test "get_service_date!/1 returns the service_date with given id" do
      service_date = service_date_fixture()
      assert Hastus.get_service_date!(service_date.id) == service_date
    end

    test "create_service_date/1 with valid data creates a service_date" do
      valid_attrs = %{start_date: ~D[2025-03-11], end_date: ~D[2025-03-11]}

      assert {:ok, %ServiceDate{} = service_date} = Hastus.create_service_date(valid_attrs)
      assert service_date.start_date == ~D[2025-03-11]
      assert service_date.end_date == ~D[2025-03-11]
    end

    test "create_service_date/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Hastus.create_service_date(@invalid_attrs)
    end

    test "update_service_date/2 with valid data updates the service_date" do
      service_date = service_date_fixture()
      update_attrs = %{start_date: ~D[2025-03-12], end_date: ~D[2025-03-12]}

      assert {:ok, %ServiceDate{} = service_date} =
               Hastus.update_service_date(service_date, update_attrs)

      assert service_date.start_date == ~D[2025-03-12]
      assert service_date.end_date == ~D[2025-03-12]
    end

    test "update_service_date/2 with invalid data returns error changeset" do
      service_date = service_date_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Hastus.update_service_date(service_date, @invalid_attrs)

      assert service_date == Hastus.get_service_date!(service_date.id)
    end

    test "delete_service_date/1 deletes the service_date" do
      service_date = service_date_fixture()
      assert {:ok, %ServiceDate{}} = Hastus.delete_service_date(service_date)
      assert_raise Ecto.NoResultsError, fn -> Hastus.get_service_date!(service_date.id) end
    end

    test "change_service_date/1 returns a service_date changeset" do
      service_date = service_date_fixture()
      assert %Ecto.Changeset{} = Hastus.change_service_date(service_date)
    end
  end
end
