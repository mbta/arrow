defmodule Arrow.Disruptions.ReplacementServiceUploadTest do
  @moduledoc false
  use Arrow.DataCase

  import ExUnit.CaptureLog
  import Arrow.Disruptions.ReplacementServiceUpload

  @xlsx_dir "test/support/fixtures/xlsx/disruption_v2_live"

  def get_xlsx(%{sheet: sheet}) do
    Xlsxir.multi_extract("#{@xlsx_dir}/#{sheet}")
  end

  def extract_single_sheet(%{sheet: sheet}) do
    [{:ok, tab0_tid} | _tabs] =
      Xlsxir.multi_extract("#{@xlsx_dir}/#{sheet}")

    name = Xlsxir.get_info(tab0_tid, :name)
    %{name: name, tid: tab0_tid}
  end

  describe "extract_data_from_upload/1" do
    @tag sheet: "example.xlsx"
    test "extracts the data from the upload", %{sheet: sheet} do
      data = extract_data_from_upload(%{path: "#{@xlsx_dir}/#{sheet}"})
      assert {:ok, {:ok, %{"version" => 1, "SAT headways and runtimes" => _sheet_data}}} = data
    end

    test "catches exceptions and returns a generic error for the user if unable to parse the upload" do
      assert capture_log(fn ->
               data = extract_data_from_upload(%{path: "#{@xlsx_dir}/"})

               error = format_warning()
               assert {:ok, {:error, [{^error, []}]}} = data
             end) =~ "ReplacementServiceUpload failed to parse XLSX"
    end
  end

  describe "get_xlsx_tab_tids/1" do
    @tag sheet: "example.xlsx"
    test "validates the spreadsheet tabs are present", context do
      tab_tids = get_xlsx(context)
      assert {:ok, _tab_map} = get_xlsx_tab_tids(tab_tids)
    end

    @tag sheet: "lowercase_tabs.xlsx"
    test "ignores case in tab names", context do
      tab_tids = get_xlsx(context)
      assert {:ok, _tab_map} = get_xlsx_tab_tids(tab_tids)
    end

    @tag sheet: "no_valid_tabs.xlsx"
    test "errors if no spreadsheet tabs match the expected format", context do
      tab_tids = get_xlsx(context)
      assert {:error, error} = get_xlsx_tab_tids(tab_tids)

      assert [
               {"Missing tab(s)",
                [
                  """
                  none found for: \
                  WKDY headways and runtimes, SAT headways and runtimes, SUN headways and runtimes\
                  """
                ]}
             ] =
               error
    end
  end

  describe "validate_headers/1" do
    @tag sheet: "example.xlsx"
    test "validates the spreadsheet headers are in the expected format", context do
      %{tid: tab0_tid} = extract_single_sheet(context)
      tab = get_tab_rows(tab0_tid)
      assert {:ok, headers} = validate_headers(tab)

      assert headers == [
               "Start time",
               "End time",
               "Headway",
               "Running time (Direction 0, Southbound to North Station)",
               "Running time (Direction 1, Northbound to Oak Grove)"
             ]
    end

    @tag sheet: "missing_header.xlsx"
    test "errors if the spreadsheet headers are not in the expected format", context do
      %{tid: tab0_tid} = extract_single_sheet(context)
      tab = get_tab_rows(tab0_tid)
      assert {:error, error} = validate_headers(tab)

      assert [
               """
               Invalid header: column not found for Headway. \
               expected: Start time, End time, Headway, Running time (Direction 0, ...), Running time (Direction 1, ...)\
               """
             ] = error
    end
  end

  describe "parse_tab/1" do
    @tag sheet: "example.xlsx"
    test "validates the data", context do
      %{tid: tid, name: name} = extract_single_sheet(context)
      tab = get_tab_rows(tid)

      assert {
               :ok,
               {
                 "WKDY headways and runtimes",
                 [
                   %{
                     start_time: "05:00",
                     end_time: "06:00",
                     headway: 3,
                     running_time_0: 40,
                     running_time_1: 28
                   }
                   | _rest
                 ]
               }
             } = parse_tab({name, tab})
    end

    @tag sheet: "bad_last_time.xlsx"
    test "errors if the data is invalid", context do
      %{tid: tid, name: name} = extract_single_sheet(context)
      tab = get_tab_rows(tid)

      assert {
               :error,
               {
                 "SUN headways and runtimes",
                 [{23, {:error, [last_trip_0: "invalid time: 24:80"]}}]
               }
             } = parse_tab({name, tab})
    end

    @tag sheet: "missing_first_last_trip.xlsx"
    test "errors if the data is missing first and last trip times", context do
      %{tid: tid, name: name} = extract_single_sheet(context)
      tab = get_tab_rows(tid)

      assert {
               :error,
               {
                 "SUN headways and runtimes",
                 ["Missing row for First and Last trip times"]
               }
             } = parse_tab({name, tab})
    end

    @tag sheet: "duplicate_first_trip.xlsx"
    test "errors if there is more than one first trip or last trip row", context do
      %{tid: tid, name: name} = extract_single_sheet(context)
      tab = get_tab_rows(tid)

      assert {
               :error,
               {
                 "WKDY headways and runtimes",
                 ["Duplicate row(s) for first trip times"]
               }
             } = parse_tab({name, tab})
    end

    @tag sheet: "headways_missing_final_row.xlsx"
    test "errors if last runtime row is before last trip", context do
      %{tid: tid, name: name} = extract_single_sheet(context)
      tab = get_tab_rows(tid)

      assert {
               :error,
               {
                 "WKDY headways and runtimes",
                 ["Missing rows for hour(s) 25:00"]
               }
             } = parse_tab({name, tab})
    end

    @tag sheet: "headways_missing_first_row.xlsx"
    test "errors if first runtime row is after first trip", context do
      %{tid: tid, name: name} = extract_single_sheet(context)
      tab = get_tab_rows(tid)

      assert {
               :error,
               {
                 "WKDY headways and runtimes",
                 ["Missing rows for hour(s) 05:00"]
               }
             } = parse_tab({name, tab})
    end

    @tag sheet: "headways_missing_middle_row.xlsx"
    test "errors if a midday runtime row is missing", context do
      %{tid: tid, name: name} = extract_single_sheet(context)
      tab = get_tab_rows(tid)

      assert {
               :error,
               {
                 "WKDY headways and runtimes",
                 ["Missing rows for hour(s) 12:00"]
               }
             } = parse_tab({name, tab})
    end

    @tag sheet: "headways_missing_first_and_final_row.xlsx"
    test "lists all missing runtime rows", context do
      %{tid: tid, name: name} = extract_single_sheet(context)
      tab = get_tab_rows(tid)

      assert {
               :error,
               {
                 "WKDY headways and runtimes",
                 ["Missing rows for hour(s) 05:00, 25:00"]
               }
             } = parse_tab({name, tab})
    end

    @tag sheet: "headways_multi_hour_rows.xlsx"
    test "accepts multi-hour runtime rows", context do
      %{tid: tid, name: name} = extract_single_sheet(context)
      tab = get_tab_rows(tid)

      assert {
               :ok,
               {
                 "WKDY headways and runtimes",
                 [
                   %{
                     start_time: "05:00",
                     end_time: "12:00",
                     headway: 5,
                     running_time_0: 30,
                     running_time_1: 27
                   },
                   %{
                     start_time: "12:00",
                     end_time: "26:00",
                     headway: 4,
                     running_time_0: 33,
                     running_time_1: 28
                   }
                   | _rest
                 ]
               }
             } = parse_tab({name, tab})
    end

    @tag sheet: "first_after_last.xlsx"
    test "errors if first trip is after last trip", context do
      %{tid: tid, name: name} = extract_single_sheet(context)
      tab = get_tab_rows(tid)

      assert {
               :error,
               {
                 "SAT headways and runtimes",
                 ["First trip times must be after Last trip times"]
               }
             } = parse_tab({name, tab})
    end
  end

  describe "parse_row/1" do
    test "parses a row of runtime data" do
      %{
        start_time: {:ok, "12:00"},
        end_time: {:ok, "13:00"},
        headway: {:ok, 6.6},
        running_time_0: {:ok, 50},
        running_time_1: {:ok, 45}
      } = parse_row(["12:00", "13:00", 6.6, 50, 45])
    end

    test "parses a row of first trip data" do
      %{
        first_trip_0: {:ok, "06:00"},
        first_trip_1: {:ok, "05:30"}
      } = parse_row(["First 06:00", "First 05:30"])
    end

    test "parses a row of last trip data" do
      %{
        last_trip_0: {:ok, "25:00"},
        last_trip_1: {:ok, "24:15"}
      } = parse_row(["Last 25:00", "Last 24:15"])
    end

    test "errors if a row is not as expected" do
      {:error, "malformed row, unexpected values" <> _rest} =
        parse_row(["invalid", "row", nil, nil])
    end
  end

  describe "parse_time/1" do
    test "parses a time string formatted as hh:mm" do
      assert {:ok, time_string} = parse_time("12:35")

      assert "12:35" = time_string
    end

    test "parses a time string after midnight times for the same service day" do
      assert {:ok, time_string} = parse_time("25:01")

      assert "25:01" = time_string
    end

    test "parses a time string that is missing a leading 0 and adds padding" do
      assert {:ok, time_string} = parse_time("8:00")

      assert "08:00" = time_string
    end

    test "parses a time string after midnight with seconds and truncates" do
      assert {:ok, time_string} = parse_time("24:00:00")

      assert "24:00" = time_string
    end

    test "parses a time string with seconds and truncates" do
      assert {:ok, time_string} = parse_time("08:00:00")

      assert "08:00" = time_string
    end

    test "parses a time string with seconds that is missing a leading 0 and adds padding" do
      assert {:ok, time_string} = parse_time("8:00:00")

      assert "08:00" = time_string
    end

    test "errors with a time string too far after midnight to be the same service day" do
      assert {:error, time_string} = parse_time("29:01")

      assert "invalid time: 29:01" = time_string
    end

    test "parses NaiveDateTime with valid format" do
      assert {:ok, time_string} =
               parse_time(%NaiveDateTime{
                 hour: 5,
                 minute: 1,
                 year: 2025,
                 month: 1,
                 day: 1,
                 second: 0
               })

      assert "05:01" = time_string
    end

    test "parses NaiveDateTime with valid format after noon" do
      assert {:ok, time_string} =
               parse_time(%NaiveDateTime{
                 hour: 15,
                 minute: 1,
                 year: 2025,
                 month: 1,
                 day: 1,
                 second: 0
               })

      assert "15:01" = time_string
    end

    test "errors with NaiveDateTime with possibly ambiguous after midnight values" do
      assert {:error, time_string} =
               parse_time(%NaiveDateTime{
                 hour: 1,
                 minute: 1,
                 year: 2025,
                 month: 1,
                 day: 1,
                 second: 0
               })

      assert "invalid time: 01:01:00, expecting times after midnight as 25:01" = time_string
    end

    test "errors with an erlang :calendar_date value for time" do
      days = :calendar.date_to_gregorian_days(2025, 1, 1)

      assert {:error, time_string} =
               parse_time(:calendar.gregorian_days_to_date(days))

      assert "invalid time: date 2025-01-01" = time_string
    end
  end

  describe "parse_number/1" do
    test "succeeds if passed a number" do
      assert {:ok, 3} = parse_number(3)
    end

    test "errors if passed a number as a string (not expected from input)" do
      assert {:error, "invalid number: 3"} = parse_number("3")
    end

    test "errors if passed a string" do
      assert {:error, "invalid number: some_string"} = parse_number("some_string")
    end

    test "errors if passed a NaiveDateTime" do
      assert {:error, number} =
               parse_number(%NaiveDateTime{
                 hour: 15,
                 minute: 1,
                 year: 2025,
                 month: 1,
                 day: 1,
                 second: 0
               })

      assert "invalid number: 15:01:00" = number
    end

    test "errors if passed an erlang :calendar_date" do
      days = :calendar.date_to_gregorian_days(2025, 1, 1)

      assert {:error, number} =
               parse_number(:calendar.gregorian_days_to_date(days))

      assert "invalid number: date 2025-01-01" = number
    end
  end
end
