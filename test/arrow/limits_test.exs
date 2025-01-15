defmodule Arrow.LimitsTest do
  use Arrow.DataCase

  alias Arrow.{GtfsFixtures, Limits}

  describe "limits" do
    alias Arrow.Disruptions.Limit

    import Arrow.LimitsFixtures

    @invalid_attrs %{start_date: nil, end_date: nil}

    test "list_limits/0 returns all limits" do
      limit = limit_fixture()
      assert Limits.list_limits() == [Repo.preload(limit, [:route, :start_stop, :end_stop])]
    end

    test "get_limit!/1 returns the limit with given id" do
      limit = limit_fixture()
      assert Limits.get_limit!(limit.id) == Repo.preload(limit, [:route, :start_stop, :end_stop])
    end

    test "create_limit/1 with valid data creates a limit" do
      route = GtfsFixtures.route_fixture()
      start_stop = GtfsFixtures.stop_fixture()
      end_stop = GtfsFixtures.stop_fixture()

      valid_attrs = %{
        start_date: ~D[2025-01-08],
        end_date: ~D[2025-01-09],
        start_stop_id: start_stop.id,
        end_stop_id: end_stop.id,
        route_id: route.id
      }

      assert {:ok, %Limit{} = limit} = Limits.create_limit(valid_attrs)
      assert limit.start_date == ~D[2025-01-08]
      assert limit.end_date == ~D[2025-01-09]
    end

    test "create_limit/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Limits.create_limit(@invalid_attrs)
    end

    test "update_limit/2 with valid data updates the limit" do
      route = GtfsFixtures.route_fixture()
      start_stop = GtfsFixtures.stop_fixture()
      end_stop = GtfsFixtures.stop_fixture()

      limit =
        limit_fixture(start_stop_id: start_stop.id, end_stop_id: end_stop.id, route_id: route.id)

      update_attrs = %{start_date: ~D[2025-01-09], end_date: ~D[2025-01-10]}

      assert {:ok, %Limit{} = limit} = Limits.update_limit(limit, update_attrs)
      assert limit.start_date == ~D[2025-01-09]
      assert limit.end_date == ~D[2025-01-10]
    end

    test "update_limit/2 with invalid data returns error changeset" do
      route = GtfsFixtures.route_fixture()
      start_stop = GtfsFixtures.stop_fixture()
      end_stop = GtfsFixtures.stop_fixture()

      limit =
        limit_fixture(start_stop_id: start_stop.id, end_stop_id: end_stop.id, route_id: route.id)

      assert {:error, %Ecto.Changeset{}} = Limits.update_limit(limit, @invalid_attrs)
      assert Repo.preload(limit, [:route, :start_stop, :end_stop]) == Limits.get_limit!(limit.id)
    end

    test "delete_limit/1 deletes the limit" do
      limit = limit_fixture()
      assert {:ok, %Limit{}} = Limits.delete_limit(limit)
      assert_raise Ecto.NoResultsError, fn -> Limits.get_limit!(limit.id) end
    end

    test "change_limit/1 returns a limit changeset" do
      limit = limit_fixture()
      assert %Ecto.Changeset{} = Limits.change_limit(limit)
    end
  end

  describe "limit_day_of_weeks" do
    alias Arrow.Limits.LimitDayOfWeek

    import Arrow.LimitsFixtures

    @invalid_attrs %{day_name: nil, start_time: nil, end_time: nil}

    test "list_limit_day_of_weeks/0 returns all limit_day_of_weeks" do
      limit_day_of_week = limit_day_of_week_fixture()
      assert Limits.list_limit_day_of_weeks() == [limit_day_of_week]
    end

    test "get_limit_day_of_week!/1 returns the limit_day_of_week with given id" do
      limit_day_of_week = limit_day_of_week_fixture()
      assert Limits.get_limit_day_of_week!(limit_day_of_week.id) == limit_day_of_week
    end

    test "create_limit_day_of_week/1 with valid data creates a limit_day_of_week" do
      valid_attrs = %{day_name: "monday", start_time: ~T[13:00:00], end_time: ~T[14:00:00]}

      assert {:ok, %LimitDayOfWeek{} = limit_day_of_week} =
               Limits.create_limit_day_of_week(valid_attrs)

      assert limit_day_of_week.day_name == "monday"
      assert limit_day_of_week.start_time == ~T[13:00:00]
      assert limit_day_of_week.end_time == ~T[14:00:00]
    end

    test "create_limit_day_of_week/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Limits.create_limit_day_of_week(@invalid_attrs)
    end

    test "update_limit_day_of_week/2 with valid data updates the limit_day_of_week" do
      limit_day_of_week = limit_day_of_week_fixture()

      update_attrs = %{
        day_name: "tuesday",
        start_time: ~T[15:01:01],
        end_time: ~T[16:01:01]
      }

      assert {:ok, %LimitDayOfWeek{} = limit_day_of_week} =
               Limits.update_limit_day_of_week(limit_day_of_week, update_attrs)

      assert limit_day_of_week.day_name == "tuesday"
      assert limit_day_of_week.start_time == ~T[15:01:01]
      assert limit_day_of_week.end_time == ~T[16:01:01]
    end

    test "update_limit_day_of_week/2 with invalid data returns error changeset" do
      limit_day_of_week = limit_day_of_week_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Limits.update_limit_day_of_week(limit_day_of_week, @invalid_attrs)

      assert limit_day_of_week == Limits.get_limit_day_of_week!(limit_day_of_week.id)
    end

    test "delete_limit_day_of_week/1 deletes the limit_day_of_week" do
      limit_day_of_week = limit_day_of_week_fixture()
      assert {:ok, %LimitDayOfWeek{}} = Limits.delete_limit_day_of_week(limit_day_of_week)

      assert_raise Ecto.NoResultsError, fn ->
        Limits.get_limit_day_of_week!(limit_day_of_week.id)
      end
    end

    test "change_limit_day_of_week/1 returns a limit_day_of_week changeset" do
      limit_day_of_week = limit_day_of_week_fixture()
      assert %Ecto.Changeset{} = Limits.change_limit_day_of_week(limit_day_of_week)
    end
  end
end
