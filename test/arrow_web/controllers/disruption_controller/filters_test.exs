defmodule ArrowWeb.DisruptionController.FiltersTest do
  use ExUnit.Case, async: true

  alias ArrowWeb.DisruptionController.Filters
  alias ArrowWeb.DisruptionController.Filters.{Calendar, Table}

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

    test "search is indicated with a param if not nil or empty" do
      assert_equivalent(%{"search" => "test"}, %Filters{search: "test"})
      assert from_params(%{"search" => nil}) == %Filters{search: nil}
      assert from_params(%{"search" => ""}) == %Filters{search: nil}
      assert to_params(%Filters{search: nil}) == %{}
    end

    test "routes are indicated with a list param if not empty" do
      assert_equivalent(%{"routes" => ["Blue", "Red"]}, %Filters{routes: set(~w(Red Blue))})
      assert from_params(%{"routes" => []}) == %Filters{routes: set()}
      assert to_params(%Filters{routes: set()}) == %{}
    end

    test "table view: include_past is indicated with a param if true" do
      assert_equivalent(%{"include_past" => "true"}, %Filters{view: %Table{include_past: true}})
      assert from_params(%{"include_past" => "abc"}) == %Filters{view: %Table{include_past: true}}
      assert from_params(%{"include_past" => nil}) == %Filters{view: %Table{include_past: false}}
      assert to_params(%Filters{view: %Table{include_past: false}}) == %{}
    end

    test "table view: sort has a default and can be expressed as ascending or descending" do
      assert_equivalent(%{}, %Filters{view: %Table{sort: {:asc, :source_label}}})
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
      routes = set(~w(Red Blue))
      calendar_filters = %Filters{routes: routes, search: "test", view: %Calendar{}}
      table_filters = %{calendar_filters | view: %Table{include_past: true, sort: {:asc, :id}}}

      assert Filters.flatten(calendar_filters) == %{routes: routes, search: "test"}
      table_expected = %{routes: routes, search: "test", include_past: true, sort: {:asc, :id}}
      assert Filters.flatten(table_filters) == table_expected
    end
  end

  describe "resettable?/1" do
    test "is true if any base or view-specific filters do not have their default values" do
      refute Filters.resettable?(%Filters{})
      refute Filters.resettable?(%Filters{view: %Calendar{}})
      assert Filters.resettable?(%Filters{search: "test"})
      assert Filters.resettable?(%Filters{view: %Table{include_past: true}})
    end

    test "does not treat the sort field of the table view as resettable" do
      refute Filters.resettable?(%Filters{view: %Table{sort: {:asc, :something}}})
    end
  end

  describe "reset/1" do
    test "resets filters to their default values without changing the view" do
      filters = %Filters{search: "test", routes: set(~w(Red)), view: %Table{include_past: true}}
      assert Filters.reset(filters) == %Filters{}
      assert Filters.reset(%{filters | view: %Calendar{}}) == %Filters{view: %Calendar{}}
    end

    test "does not reset the sort field of the table view" do
      filters = %Filters{view: %Table{sort: {:asc, :something}}}
      assert Filters.reset(filters) == filters
    end
  end

  describe "toggle_route/2" do
    test "adds the given route to the route filter if it is not present" do
      filters = %Filters{routes: set(~w(Red))}
      assert Filters.toggle_route(filters, "Blue") == %Filters{routes: set(~w(Red Blue))}
    end

    test "removes the given route from the route filter if it is present" do
      filters = %Filters{routes: set(~w(Red Blue))}
      assert Filters.toggle_route(filters, "Red") == %Filters{routes: set(~w(Blue))}
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
      filters = %Filters{search: "test", routes: set(~w(Red Blue))}

      expected = [{"routes[]", "Blue"}, {"routes[]", "Red"}, {"search", "test"}]
      assert Filters.to_flat_params(filters) == expected
    end
  end
end
