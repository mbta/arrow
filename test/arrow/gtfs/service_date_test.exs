defmodule Arrow.Gtfs.AgencyTest do
  use Arrow.DataCase
  alias Arrow.Gtfs.Service
  alias Arrow.Gtfs.ServiceDate

  describe "database" do
    test "enforces string FK constraints and integer-coded values, parses datestamps" do
      service_id = "OL-Weekend-September"

      service_attrs = %{
        "service_id" => service_id,
        "monday" => "0",
        "tuesday" => "0",
        "wednesday" => "0",
        "thursday" => "0",
        "friday" => "0",
        "saturday" => "1",
        "sunday" => "1",
        "start_date" => "20240901",
        "end_date" => "20240930"
      }

      cs = Service.changeset(%Service{}, service_attrs)
      assert {:ok, new_service} = Repo.insert(cs)

      service_date_attrs = %{
        "service_id" => service_id,
        "date" => "20240905",
        "exception_type" => "1",
        "holiday_name" => ""
      }

      cs = ServiceDate.changeset(%ServiceDate{}, service_date_attrs)
      assert {:ok, new_service_date} = Repo.insert(cs)

      assert [service_date] = Repo.all(Ecto.assoc(new_service, :dates))

      assert {service_date.service_id, service_date.date} ==
               {new_service_date.service_id, new_service_date.date}

      assert %Date{} = new_service_date.date
      assert new_service_date.exception_type == :added
    end
  end
end
