defmodule Arrow.Slack.Notifier do
  alias Arrow.DisruptionRevision
  alias Arrow.Slack.DisruptionNotification

  @spec created(DisruptionRevision.t()) :: HTTPoison.Response.t()
  def created(rev) do
    %DisruptionNotification{
      revision: rev,
      status: :created
    }
    |> send_notification()
  end

  @spec edited(DisruptionRevision.t(), DisruptionRevision.t()) :: HTTPoison.Response.t()
  def edited(initial, revised) do
    %DisruptionNotification{
      revision: revised,
      initial: initial,
      status: :edited
    }
    |> send_notification()
  end

  @spec cancelled(DisruptionRevision.t()) :: HTTPoison.Response.t()
  def cancelled(rev) do
    %DisruptionNotification{
      revision: rev,
      status: :cancelled
    }
    |> send_notification()
  end

  @spec send_notification(DisruptionNotification.t()) :: HTTPoison.Response.t()
  defp send_notification(%DisruptionNotification{} = notification) do
    url = System.get_env("SLACK_WEBHOOK_DEV")

    body = DisruptionNotification.format(notification)

    if body do
      HTTPoison.post!(url, body, "content-type": "application/json")
    end
  end
end
