defmodule ArrowWeb.API.NoticeController do
  use ArrowWeb, :controller
  require Logger

  @spec publish(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def publish(conn, params) do
    try do
      revision_ids =
        params["revision_ids"]
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)

      :ok = Arrow.DisruptionRevision.publish!(revision_ids)

      :ok = Logger.info("marking_revisions_published revision_ids=#{params["revision_ids"]}")

      send_resp(conn, 200, "")
    rescue
      ArgumentError ->
        send_resp(conn, 400, "bad argument")

      Arrow.Disruption.Error.PublishedAfterReady ->
        send_resp(conn, 400, "can't publish revision more recent than ready revision")
    end
  end

  @spec ready(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def ready(conn, params) do
    try do
      revision_ids =
        params["revision_ids"]
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)

      :ok = Arrow.DisruptionRevision.ready!(revision_ids)

      :ok = Logger.info("marking_revisions_ready revision_ids=#{params["revision_ids"]}")

      send_resp(conn, 204, "")
    rescue
      ArgumentError ->
        send_resp(conn, 400, "bad argument")

      Arrow.Disruption.Error.ReadyNotLatest ->
        send_resp(conn, 400, "can't ready revision more recent than latest revision")
    end
  end
end
