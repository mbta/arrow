defmodule ArrowWeb.DisruptionV2Live.Show do
  use ArrowWeb, :live_view

  alias Arrow.Disruptions

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:disruption_v2, Disruptions.get_disruption_v2!(id))}
  end

  defp page_title(:show), do: "Show Disruption v2"
  defp page_title(:edit), do: "Edit Disruption v2"
end
