defmodule ArrowWeb.DisruptionV2Controller.FiltersTest do
  use ExUnit.Case, async: true

  alias ArrowWeb.DisruptionV2Controller.Filters
  alias ArrowWeb.DisruptionV2Controller.Filters.{Calendar, Table}

  defp set(items \\ []), do: MapSet.new(items)

  describe "from_params/1 and to_params/1" do
    import Filters, only: [from_params: 1, to_params: 1]

    defp assert_equivalent(params, struct) do
      assert from_params(params) == struct
      assert to_params(struct) == params
    end

    test "table view with default filters is an empty map" do
      assert_equivalent(%{}, %Filters{view: %Table{}})
    end

    test "calendar view is indicated with a param" do
      assert_equivalent(%{"view" => "calendar"}, %Filters{view: %Calendar{}})
    end

    test "kinds are indicated with a list param if not empty" do
      assert_equivalent(
        %{"kinds" => ["blue_line", "red_line"]},
        %Filters{kinds: set(~w(red_line blue_line)a)}
      )

      assert from_params(%{"kinds" => []}) == %Filters{kinds: set()}
      assert to_params(%Filters{kinds: set()}) == %{}
    end

    test "table view: include_past is indicated with a param if true" do
      assert_equivalent(%{"include_past" => "true"}, %Filters{view: %Table{include_past?: true}})

      assert from_params(%{"include_past" => "abc"}) == %Filters{
               view: %Table{include_past?: true}
             }

      assert from_params(%{"include_past" => nil}) == %Filters{view: %Table{include_past?: false}}
      assert to_params(%Filters{view: %Table{include_past?: false}}) == %{}
    end

    test "table view: sort has a default and can be expressed as ascending or descending" do
      assert_equivalent(%{}, %Filters{view: %Table{sort: {:asc, :start_date}}})
      assert_equivalent(%{"sort" => "id"}, %Filters{view: %Table{sort: {:asc, :id}}})
      assert_equivalent(%{"sort" => "-id"}, %Filters{view: %Table{sort: {:desc, :id}}})
    end
  end

  describe "calendar?/1" do
    test "indicates whether the calendar view is active" do
      assert Filters.calendar?(%Filters{view: %Calendar{}})
      refute Filters.calendar?(%Filters{view: %Table{}})
    end
  end

  describe "flatten/1" do
    test "flattens base and view-specific filters into a map" do
      kinds = set(~w(commuter_rail silver_line))
      calendar_filters = %Filters{kinds: kinds, search: "test", view: %Calendar{}}
      table_filters = %{calendar_filters | view: %Table{include_past?: true, sort: {:asc, :id}}}

      assert Filters.flatten(calendar_filters) == %{
               kinds: kinds,
               only_approved?: false,
               search: "test"
             }

      table_expected = %{
        kinds: kinds,
        search: "test",
        include_past?: true,
        only_approved?: false,
        sort: {:asc, :id}
      }

      assert Filters.flatten(table_filters) == table_expected
    end
  end

  describe "resettable?/1" do
    test "is true if any base or view-specific filters do not have their default values" do
      refute Filters.resettable?(%Filters{})
      refute Filters.resettable?(%Filters{view: %Calendar{}})
      assert Filters.resettable?(%Filters{search: "test"})
      assert Filters.resettable?(%Filters{view: %Table{include_past?: true}})
      assert Filters.resettable?(%Filters{only_approved?: true})
    end

    test "does not treat the sort field of the table view as resettable" do
      refute Filters.resettable?(%Filters{view: %Table{sort: {:asc, :something}}})
    end
  end

  describe "reset/1" do
    test "resets filters to their default values without changing the view" do
      filters = %Filters{
        search: "test",
        kinds: set(~w(red_line)),
        only_approved?: true,
        view: %Table{include_past?: true}
      }

      assert Filters.reset(filters) == %Filters{}
      assert Filters.reset(%{filters | view: %Calendar{}}) == %Filters{view: %Calendar{}}
    end

    test "does not reset the sort field of the table view" do
      filters = %Filters{view: %Table{sort: {:asc, :something}}}
      assert Filters.reset(filters) == filters
    end
  end

  describe "toggle_kind/2" do
    test "adds the given kind to the kinds filter if it is not present" do
      filters = %Filters{kinds: set(~w(red_line)a)}
      assert Filters.toggle_kind(filters, :bus) == %Filters{kinds: set(~w(red_line bus)a)}
    end

    test "removes the given kind from the kinds filter if it is present" do
      filters = %Filters{kinds: set(~w(red_line blue_line)a)}
      assert Filters.toggle_kind(filters, :red_line) == %Filters{kinds: set(~w(blue_line)a)}
    end
  end

  describe "toggle_view/1" do
    test "toggles the active view between Calendar and Table" do
      assert Filters.toggle_view(%Filters{view: %Calendar{}}) == %Filters{view: %Table{}}
      assert Filters.toggle_view(%Filters{view: %Table{}}) == %Filters{view: %Calendar{}}
    end
  end

  describe "to_flat_params/1" do
    test "functions as to_params/1 but flattens lists into query-param format" do
      filters = %Filters{search: "test", kinds: set(~w(red_line blue_line)a)}

      expected = [{"kinds[]", "blue_line"}, {"kinds[]", "red_line"}, {"search", "test"}]
      assert Filters.to_flat_params(filters) == expected
    end
  end
end
