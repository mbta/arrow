defmodule ArrowWeb.HealthController do
  @moduledoc """
  Simple controller to return 200 OK when website is running. This
  is used by the AWS ALB to determine the health of the target.
  """
  use ArrowWeb, :controller

  def index(conn, _params) do
    send_resp(conn, 200, "")
  end
end
