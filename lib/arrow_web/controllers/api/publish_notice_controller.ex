defmodule ArrowWeb.API.PublishNoticeController do
  use ArrowWeb, :controller
  require Logger

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, params) do
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

      Arrow.Disruption.PublishedAfterReadyError ->
        send_resp(conn, 400, "can't publish revision more recent than ready revision")
    end
  end
end
