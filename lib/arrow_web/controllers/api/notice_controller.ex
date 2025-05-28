defmodule ArrowWeb.API.NoticeController do
  alias ArrowWeb.Plug.Authorize
  use ArrowWeb, :controller
  require Logger

  plug(Authorize, :publish_notice)

  @spec publish(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def publish(conn, %{"revision_ids" => ""}) do
    send_resp(conn, 200, "")
  end

  def publish(conn, params) do
    revision_ids = params["revision_ids"] |> String.split(",") |> Enum.map(&String.to_integer/1)

    :ok = Arrow.DisruptionRevision.publish!(revision_ids)
    :ok = Logger.info("marking_revisions_published revision_ids=#{params["revision_ids"]}")

    send_resp(conn, 200, "")
  rescue
    ArgumentError ->
      send_resp(conn, 400, "bad argument")
  end
end
