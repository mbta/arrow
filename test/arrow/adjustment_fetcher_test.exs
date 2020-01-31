defmodule Arrow.PredictionFetcherTest do
  use ExUnit.Case

  @test_json_filename "test_adjustments.json"

  @test_json [%{id: "foo", attributes: %{route_id: "bar"}}] |> Jason.encode!()

  setup do
    on_exit(fn -> File.rm_rf!(@test_json_filename) end)

    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Arrow.Repo)

    File.write!(@test_json_filename, @test_json)
  end

  describe "init/1" do
    test "inserts data" do
      :ignore = Arrow.AdjustmentFetcher.init(path: @test_json_filename)

      assert [%Arrow.Adjustment{source_label: "foo", route_id: "bar", source: "gtfs_creator"}] =
               Arrow.Repo.all(Arrow.Adjustment)
    end

    test "updates source if an adjustment with the same label already exists" do
      adj = %Arrow.Adjustment{
        source: "arrow",
        source_label: "foo",
        route_id: "bar"
      }

      {:ok, _new_adj} = Arrow.Repo.insert(adj)

      :ignore = Arrow.AdjustmentFetcher.init(path: @test_json_filename)

      assert [%Arrow.Adjustment{source_label: "foo", source: "gtfs_creator"}] =
               Arrow.Repo.all(Arrow.Adjustment)
    end
  end
end
