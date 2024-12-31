defmodule Arrow.Account.UserTest do
  use ExUnit.Case
  alias Arrow.Accounts.User

  test "roles is a MapSet" do
    assert %User{
             id: "me@example.com",
             roles: MapSet.new()
           } == %User{
             id: "me@example.com"
           }
  end
end
