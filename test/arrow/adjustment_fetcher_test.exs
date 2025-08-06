defmodule Arrow.AdjustmentFetcherTest do
  use Arrow.DataCase

  import Arrow.Factory
  import ExUnit.CaptureLog
  import Mox

  alias Arrow.Adjustment
  alias Arrow.AdjustmentFetcher
  alias Arrow.HTTPMock
  alias Arrow.Repo

  @test_json Jason.encode!([%{id: "foo", attributes: %{route_id: "bar"}}])

  setup :verify_on_exit!

  describe "start_link/1" do
    test "fetches adjustments on an interval and warns on failure" do
      parent = self()

      successful_get = fn _url ->
        send(parent, :requested)
        {:ok, %{status_code: 200, body: @test_json}}
      end

      failed_get = fn _url ->
        send(parent, :requested)
        {:error, "it went wrong"}
      end

      log =
        capture_log(fn ->
          {:ok, fetcher} = AdjustmentFetcher.start_link(interval: 100)

          HTTPMock
          |> expect(:get, successful_get)
          |> expect(:get, failed_get)
          |> expect(:get, successful_get)
          |> allow(parent, fetcher)

          # wait for it to make all three requests, then stop it
          Enum.each(1..3, fn _ -> assert_receive :requested, 200 end)
          GenServer.stop(fetcher)
        end)

      assert log =~ "it went wrong"
    end
  end

  describe "fetch/0" do
    defp setup_successful_request do
      expect(HTTPMock, :get, fn _url -> {:ok, %{status_code: 200, body: @test_json}} end)
    end

    test "inserts data" do
      setup_successful_request()

      :ok = AdjustmentFetcher.fetch()

      assert [%Adjustment{source_label: "foo", route_id: "bar", source: "gtfs_creator"}] =
               Repo.all(Adjustment)
    end

    test "updates source if an adjustment with the same label already exists" do
      setup_successful_request()
      Repo.insert!(%Adjustment{source: "arrow", source_label: "foo", route_id: "bar"})

      :ok = AdjustmentFetcher.fetch()

      assert [%Adjustment{source_label: "foo", source: "gtfs_creator"}] = Repo.all(Adjustment)
    end

    test "removes old gtfs_creator adjustments no longer present in the JSON" do
      setup_successful_request()

      Repo.insert!(%Adjustment{
        source: "gtfs_creator",
        source_label: "no_longer_exists",
        route_id: "bar"
      })

      :ok = AdjustmentFetcher.fetch()

      assert is_nil(Repo.get_by(Adjustment, source_label: "no_longer_exists"))
    end

    test "doesn't remove old adjustments still associated with disruptions" do
      setup_successful_request()
      adjustment = insert(:adjustment)
      disruption = insert(:disruption)

      _disruption_revision =
        insert(:disruption_revision, disruption: disruption, adjustments: [adjustment])

      :ok = AdjustmentFetcher.fetch()

      refute Arrow.Adjustment
             |> Arrow.Repo.all()
             |> Enum.find(fn a -> a.source_label == adjustment.source_label end)
             |> is_nil()
    end

    test "handles a failure to fetch the adjustments" do
      expect(HTTPMock, :get, fn _url -> {:ok, %{status_code: 403, body: "forbid"}} end)
      assert {:error, %{status_code: 403}} = AdjustmentFetcher.fetch()
    end

    test "handles a failure to decode the adjustments" do
      expect(HTTPMock, :get, fn _url -> {:ok, %{status_code: 200, body: "not JSON"}} end)
      assert {:error, %Jason.DecodeError{}} = AdjustmentFetcher.fetch()
    end

    test "leaves existing adjustments intact on failure" do
      Repo.insert!(%Adjustment{source: "gtfs_creator", source_label: "foo", route_id: "bar"})
      expect(HTTPMock, :get, fn _url -> {:error, "oops"} end)
      AdjustmentFetcher.fetch()

      assert [%Adjustment{source_label: "foo", source: "gtfs_creator"}] = Repo.all(Adjustment)
    end
  end
end
