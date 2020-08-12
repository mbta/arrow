defmodule Arrow.PredictionFetcherTest do
  use ExUnit.Case
  import Arrow.Factory

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

    test "cleans out old gtfs_creator adjustments no longer present in the JSON" do
      adj = %Arrow.Adjustment{
        source: "gtfs_creator",
        source_label: "no_longer_exists",
        route_id: "bar"
      }

      {:ok, _new_adj} = Arrow.Repo.insert(adj)

      :ignore = Arrow.AdjustmentFetcher.init(path: @test_json_filename)

      assert is_nil(Arrow.Repo.get_by(Arrow.Adjustment, source_label: "no_longer_exists"))
    end

    test "doesn't remove adjustments that are no longer present if they're still associated with disruptions" do
      adjustment = insert(:adjustment)
      disruption = insert(:disruption)

      _disruption_revision =
        insert(:disruption_revision, disruption: disruption, adjustments: [adjustment])

      :ignore = Arrow.AdjustmentFetcher.init(path: @test_json_filename)

      refute Arrow.Adjustment
             |> Arrow.Repo.all()
             |> Enum.find(fn a -> a.source_label == adjustment.source_label end)
             |> is_nil()
    end
  end
end
