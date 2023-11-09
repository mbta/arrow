defmodule Arrow.PermissionsTest do
  use ExUnit.Case
  alias Arrow.Accounts.User
  alias Arrow.Permissions

  test "denies a non-admin trying to create a disruption" do
    refute Permissions.authorize?(:create_disruption, %User{id: "test_user", roles: MapSet.new()})
  end

  test "denies a non-admin trying to delete a disruption" do
    refute Permissions.authorize?(:delete_disruption, %User{id: "test_user", roles: MapSet.new()})
  end

  test "denies a non-admin trying to update a disruption" do
    refute Permissions.authorize?(:update_disruption, %User{id: "test_user", roles: MapSet.new()})
  end

  test "allows an admin trying to create a disruption" do
    assert Permissions.authorize?(:create_disruption, %User{
             id: "test_user",
             roles: MapSet.new(["admin"])
           })
  end

  test "allows an admin trying to delete a disruption" do
    assert Permissions.authorize?(:delete_disruption, %User{
             id: "test_user",
             roles: MapSet.new(["admin"])
           })
  end

  test "allows an admin trying to update a disruption" do
    assert Permissions.authorize?(:update_disruption, %User{
             id: "test_user",
             roles: MapSet.new(["admin"])
           })
  end
end
