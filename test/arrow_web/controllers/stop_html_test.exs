defmodule ArrowWeb.StopViewTest do
  @moduledoc false
  use ExUnit.Case

  alias ArrowWeb.StopView

  describe "format_timestamp" do
    test "formats a timestamp into Eastern time" do
      utc = DateTime.from_naive!(~N[2024-07-24T09:30:00], "Etc/UTC")
      assert StopView.format_timestamp(utc) =~ "2024-07-24 05:30 AM"
    end
  end
end
