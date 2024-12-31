defmodule ArrowWeb.DisruptionV2Live.Index do
  use ArrowWeb, :live_view

  alias Arrow.Disruptions
  alias Arrow.Disruptions.DisruptionV2

  @impl true
  def mount(%{} = _params, _session, socket) do
    disruption = %DisruptionV2{}

    gtfs_disruptable_routes = Shuttles.list_disruptable_routes()
    shapes = Shuttles.list_shapes()
    form = shuttle |> Shuttles.change_shuttle() |> to_form()

    socket =
      socket
      |> assign(:form, form)
      |> assign(:form_action, "create")
      |> assign(:http_action, ~p"/shuttles")
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

  @impl true
  def handle_info({ArrowWeb.DisruptionV2Live.FormComponent, {:saved, disruption_v2}}, socket) do
    {:noreply, stream_insert(socket, :disruptionsv2, disruption_v2)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    disruption_v2 = Disruptions.get_disruption_v2!(id)
    {:ok, _} = Disruptions.delete_disruption_v2(disruption_v2)

    {:noreply, stream_delete(socket, :disruptionsv2, disruption_v2)}
  end

end
