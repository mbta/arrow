defmodule Arrow.ApplicationTest do
  @moduledoc false
  use ExUnit.Case, async: true
  import Arrow.Application

  describe "migrate_children/1" do
    test "starts the migrator when passed true" do
      assert migrate_children(true) == [Arrow.Repo.Migrator]
    end

    test "starts nothing when passed false" do
      assert migrate_children(false) == []
    end
  end
end
