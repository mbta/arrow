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
      valid_attrs = %{
        s3_path: "foo",
        routes: [%{route_id: "CR-Worcester"}],
        services: [%{name: "test-service"}]
      }

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

  describe "trainsformer_services" do
    alias Arrow.Trainsformer.Service

    import Arrow.TrainsformerFixtures

    @invalid_attrs %{name: nil}

    test "list_trainsformer_services/0 returns all trainsformer_services" do
      service = service_fixture()
      assert Trainsformer.list_trainsformer_services() == [service]
    end

    test "get_service!/1 returns the service with given id" do
      service = service_fixture()
      assert Trainsformer.get_service!(service.id) == service
    end

    test "create_service/1 with valid data creates a service" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Service{} = service} = Trainsformer.create_service(valid_attrs)
      assert service.name == "some name"
    end

    test "create_service/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Trainsformer.create_service(@invalid_attrs)
    end

    test "update_service/2 with valid data updates the service" do
      service = service_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Service{} = service} = Trainsformer.update_service(service, update_attrs)
      assert service.name == "some updated name"
    end

    test "update_service/2 with invalid data returns error changeset" do
      service = service_fixture()
      assert {:error, %Ecto.Changeset{}} = Trainsformer.update_service(service, @invalid_attrs)
      assert service == Trainsformer.get_service!(service.id)
    end

    test "delete_service/1 deletes the service" do
      service = service_fixture()
      assert {:ok, %Service{}} = Trainsformer.delete_service(service)
      assert_raise Ecto.NoResultsError, fn -> Trainsformer.get_service!(service.id) end
    end

    test "change_service/1 returns a service changeset" do
      service = service_fixture()
      assert %Ecto.Changeset{} = Trainsformer.change_service(service)
    end
  end

  describe "trainsformer_service_dates" do
    alias Arrow.Trainsformer.ServiceDate

    import Arrow.TrainsformerFixtures

    @invalid_attrs %{start_date: nil, end_date: nil}

    test "get_service_date!/1 returns the service_date with given id" do
      service_date = service_date_fixture()
      assert Trainsformer.get_service_date!(service_date.id) == service_date
    end

    test "create_service_date/1 with valid data creates a service_date" do
      valid_attrs = %{start_date: ~D[2025-03-11], end_date: ~D[2025-03-11]}

      assert {:ok, %ServiceDate{} = service_date} = Trainsformer.create_service_date(valid_attrs)
      assert service_date.start_date == ~D[2025-03-11]
      assert service_date.end_date == ~D[2025-03-11]
    end

    test "create_service_date/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Trainsformer.create_service_date(@invalid_attrs)
    end

    test "update_service_date/2 with valid data updates the service_date" do
      service_date = service_date_fixture()
      update_attrs = %{start_date: ~D[2025-03-12], end_date: ~D[2025-03-12]}

      assert {:ok, %ServiceDate{} = service_date} =
               Trainsformer.update_service_date(service_date, update_attrs)

      assert service_date.start_date == ~D[2025-03-12]
      assert service_date.end_date == ~D[2025-03-12]
    end

    test "update_service_date/2 with invalid data returns error changeset" do
      service_date = service_date_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Trainsformer.update_service_date(service_date, @invalid_attrs)

      assert service_date == Trainsformer.get_service_date!(service_date.id)
    end

    test "delete_service_date/1 deletes the service_date" do
      service_date = service_date_fixture()
      assert {:ok, %ServiceDate{}} = Trainsformer.delete_service_date(service_date)
      assert_raise Ecto.NoResultsError, fn -> Trainsformer.get_service_date!(service_date.id) end
    end

    test "change_service_date/1 returns a service_date changeset" do
      service_date = service_date_fixture()
      assert %Ecto.Changeset{} = Trainsformer.change_service_date(service_date)
    end
  end
end
