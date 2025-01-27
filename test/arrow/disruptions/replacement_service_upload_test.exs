defmodule Arrow.Disruptions.ReplacementServiceUploadTest do
  @moduledoc false
  use Arrow.DataCase

  import Arrow.Disruptions.ReplacementServiceUpload

  def get_xlsx(%{sheet: sheet}) do
    Xlsxir.multi_extract("test/support/fixtures/xlsx/disruption_v2_live/#{sheet}")
  end

  def extract_single_sheet(%{sheet: sheet}) do
    [{:ok, tab0_tid} | _tabs] =
      Xlsxir.multi_extract("test/support/fixtures/xlsx/disruption_v2_live/#{sheet}")

    name = Xlsxir.get_info(tab0_tid, :name)
    %{name: name, tid: tab0_tid}
  end

  describe "get_xlsx_tab_tids/1" do
    @tag sheet: "example.xlsx"
    test "validates the spreadsheet tabs are present", context do
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
      tab = get_tab(tab0_tid)
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
      tab = get_tab(tab0_tid)
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
             } = parse_tab({name, tid})
    end

    @tag sheet: "bad_last_time.xlsx"
    test "errors if the data is invalid", context do
      %{tid: tid, name: name} = extract_single_sheet(context)

      assert {
               :error,
               {
                 "SUN headways and runtimes",
                 [{23, {:error, [last_trip_0: "invalid time: 24:80"]}}]
               }
             } = parse_tab({name, tid})
    end

    @tag sheet: "missing_first_last_trip.xlsx"
    test "errors if the data is missing first and last trip times", context do
      %{tid: tid, name: name} = extract_single_sheet(context)

      assert {
               :error,
               {
                 "SUN headways and runtimes",
                 ["Missing row for First and Last trip times"]
               }
             } = parse_tab({name, tid})
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
      } = parse_row([nil, nil, nil, "First 06:00", "First 05:30"])
    end

    test "parses a row of last trip data" do
      %{
        last_trip_0: {:ok, "25:00"},
        last_trip_1: {:ok, "24:15"}
      } = parse_row([nil, nil, nil, "Last 25:00", "Last 24:15"])
    end

    test "errors if a row is not as expected" do
      {:error, "malformed row: " <> _rest} = parse_row(["invalid", "row", nil, nil])
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
  end

  describe "parse_number/1" do
    test "succeeds if passed a number" do
      assert {:ok, 3} = parse_number(3)
    end

    test "errors if passed a number as a string (not expected from input)" do
      assert {:error, "3"} = parse_number("3")
    end

    test "errors if passed a string" do
      assert {:error, "some_string"} = parse_number("some_string")
    end
  end
end
