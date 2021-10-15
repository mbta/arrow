defmodule Arrow.Account.UserTest do
  use ExUnit.Case
  alias Arrow.Accounts.User

  test "groups is a MapSet" do
    assert %User{
             id: "me@example.com",
             groups: MapSet.new()
           } == %User{
             id: "me@example.com"
           }
  end
end
