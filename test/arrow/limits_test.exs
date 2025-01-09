defmodule Arrow.LimitsTest do
  use Arrow.DataCase

  alias Arrow.Limits

  describe "limits" do
    alias Arrow.Disruptions.Limit

    import Arrow.LimitsFixtures

    @invalid_attrs %{start_date: nil, end_date: nil}

    test "list_limits/0 returns all limits" do
      limit = limit_fixture()
      assert Limits.list_limits() == [limit]
    end

    test "get_limit!/1 returns the limit with given id" do
      limit = limit_fixture()
      assert Limits.get_limit!(limit.id) == limit
    end

    test "create_limit/1 with valid data creates a limit" do
      valid_attrs = %{start_date: ~U[2025-01-08 13:44:00Z], end_date: ~U[2025-01-08 13:44:00Z]}

      assert {:ok, %Limit{} = limit} = Limits.create_limit(valid_attrs)
      assert limit.start_date == ~U[2025-01-08 13:44:00Z]
      assert limit.end_date == ~U[2025-01-08 13:44:00Z]
    end

    test "create_limit/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Limits.create_limit(@invalid_attrs)
    end

    test "update_limit/2 with valid data updates the limit" do
      limit = limit_fixture()
      update_attrs = %{start_date: ~U[2025-01-09 13:44:00Z], end_date: ~U[2025-01-09 13:44:00Z]}

      assert {:ok, %Limit{} = limit} = Limits.update_limit(limit, update_attrs)
      assert limit.start_date == ~U[2025-01-09 13:44:00Z]
      assert limit.end_date == ~U[2025-01-09 13:44:00Z]
    end

    test "update_limit/2 with invalid data returns error changeset" do
      limit = limit_fixture()
      assert {:error, %Ecto.Changeset{}} = Limits.update_limit(limit, @invalid_attrs)
      assert limit == Limits.get_limit!(limit.id)
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
end
