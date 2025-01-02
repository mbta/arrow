defmodule ArrowWeb.DisruptionV2ViewLive do
  use ArrowWeb, :live_view

  alias Arrow.Disruptions
  alias Arrow.Disruptions.DisruptionV2

  embed_templates "disruption_v2_live/*"

  @impl true
  def mount(%{} = _params, _session, socket) do
    socket =
      socket
      |> assign(:form_action, "create")
      |> assign(:http_action, ~p"/disruptionsv2/new")
      |> assign(:title, "Create new Disruption")
      |> assign(:errors, %{route_stops: %{}})

    {:ok, socket}

  end
  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :disruptionsv2, Disruptions.list_disruptionsv2())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Disruption v2")
    |> assign(:disruption_v2, Disruptions.get_disruption_v2!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Disruption v2")
    |> assign(:disruption_v2, %DisruptionV2{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Disruptionsv2")
    |> assign(:disruption_v2, nil)
  end
end
