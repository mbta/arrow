defmodule Arrow.Slack.Notifier do
  alias Arrow.DisruptionRevision
  alias Arrow.Slack.DisruptionNotification

  @spec created(DisruptionRevision.t()) :: HTTPoison.Response.t()
  def created(rev) do
    DisruptionNotification.format_created(rev)
    |> notify()
  end

  @spec edited(DisruptionRevision.t(), DisruptionRevision.t()) ::
          HTTPoison.Response.t()
  def edited(before, updated) do
    message = DisruptionNotification.format_edited(before, updated)

    if message do
      notify(message)
    end
  end

  @spec cancelled(DisruptionRevision.t()) :: HTTPoison.Response.t()
  def cancelled(rev) do
    DisruptionNotification.format_cancelled(rev)
    |> notify()
  end

  @spec notify(String.t()) :: HTTPoison.Response.t()
  defp notify(body) do
    url = System.get_env("SLACK_WEBHOOK_DEV")

    HTTPoison.post!(url, body, "content-type": "application/json")
  end
end
