defmodule Arrow.Gtfs.ServiceTest do
  use Arrow.DataCase
  alias Arrow.Gtfs.Calendar
  alias Arrow.Gtfs.CalendarDate
  alias Arrow.Gtfs.Service

  describe "database" do
    test "enforces string FK constraints and integer-coded values, parses datestamps" do
      service_id = "OL-Weekend-September"

      cs = Service.changeset(%Service{}, %{"id" => service_id})
      assert {:ok, service} = Repo.insert(cs)

      assert %Service{id: ^service_id} = service

      calendar_attrs = %{
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

      cs = Calendar.changeset(%Calendar{}, calendar_attrs)
      assert {:ok, calendar} = Repo.insert(cs)

      assert %Calendar{
               service_id: ^service_id,
               monday: false,
               tuesday: false,
               wednesday: false,
               thursday: false,
               friday: false,
               saturday: true,
               sunday: true,
               start_date: ~D[2024-09-01],
               end_date: ~D[2024-09-30]
             } = calendar

      calendar_date_attrs = %{
        "service_id" => service_id,
        "date" => "20240905",
        "exception_type" => "2",
        "holiday_name" => ""
      }

      cs = CalendarDate.changeset(%CalendarDate{}, calendar_date_attrs)
      assert {:ok, calendar_date} = Repo.insert(cs)

      assert %CalendarDate{
               service_id: ^service_id,
               date: ~D[2024-09-05],
               exception_type: :removed,
               holiday_name: nil
             } = calendar_date

      assert [^calendar_date] = Repo.all(Ecto.assoc(service, :calendar_dates))
    end
  end
end
