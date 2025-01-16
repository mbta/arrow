defmodule Arrow.Shuttles.ActivationUploadTest do
  @moduledoc false
  use Arrow.DataCase

  import Arrow.Shuttles.ActivationUpload

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
    @describetag :only
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
               """
               Missing tab(s), none found for: \
               WKDY headways and runtimes, SAT headways and runtimes, SUN headways and runtimes\
               """
             ] =
               error
    end
  end

  describe "validate_headers/1" do
    @describetag :only
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
    @describetag :only
    @tag sheet: "example.xlsx"
    test "validates the data", context do
      %{tid: tid, name: name} = extract_single_sheet(context)

      assert {
               :error,
               {
                 "WKDY headways and runtimes",
                 [{2, {:error, [start_time: "invalid time: 5:00:00"]}}]
               }
             } = parse_tab({name, tid})
    end
  end
end
