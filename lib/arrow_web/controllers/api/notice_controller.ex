defmodule ArrowWeb.API.NoticeController do
  use ArrowWeb, :controller
  require Logger

  @spec publish(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def publish(conn, params) do
    handle(conn, params, &Arrow.DisruptionRevision.publish!/1, "marking_revisions_published")
  end

  @spec ready(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def ready(conn, params) do
    handle(conn, params, &Arrow.DisruptionRevision.ready!/1, "marking_revisions_ready", 204)
  end

  @spec handle(Plug.Conn.t(), map(), function(), String.t(), integer()) ::
          Plug.Conn.t()
  defp handle(conn, params, update_fn, notice_event, success_status \\ 200) do
    try do
      revision_ids =
        params["revision_ids"]
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)

      :ok = update_fn.(revision_ids)

      :ok = Logger.info("#{notice_event} revision_ids=#{params["revision_ids"]}")

      send_resp(conn, success_status, "")
    rescue
      ArgumentError ->
        send_resp(conn, 400, "bad argument")

      Arrow.Disruption.Error.PublishedAfterReady ->
        send_resp(conn, 400, "can't publish revision more recent than ready revision")

      Arrow.Disruption.Error.ReadyNotLatest ->
        send_resp(conn, 400, "can't ready revision more recent than latest revision")
    end
  end
end
