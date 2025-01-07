defmodule ArrowWeb.DisruptionV2ViewLive do
  use ArrowWeb, :live_view

  alias Arrow.Adjustment
  alias Arrow.Disruptions
  alias Arrow.Disruptions.DisruptionV2

  @impl true
  def mount(%{"id" => disruption_id}, _session, socket) do
    disruption = Disruptions.get_disruption_v2!(disruption_id)

    socket =
      socket
      |> assign(:form_action, :edit)
      |> assign(:title, "edit disruption")
      |> assign(:form, Disruptions.change_disruption_v2(disruption) |> to_form)
      |> assign(:errors, %{})
      |> assign(:icon_paths, icon_paths(socket))
      |> assign(:disruption_v2, disruption)

    {:ok, socket}
  end

  @impl true
  def mount(%{} = _params, _session, socket) do
    socket =
      socket
      |> assign(:form_action, :create)
      |> assign(:http_action, ~p"/disruptionsv2/new")
      |> assign(:title, "create new disruption")
      |> assign(:form, Disruptions.change_disruption_v2(%DisruptionV2{}) |> to_form)
      |> assign(:errors, %{})
      |> assign(:icon_paths, icon_paths(socket))
      |> assign(:disruption_v2, %DisruptionV2{})

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  # handle flash messages from child components
  @impl true
  def handle_info({:put_flash, type, message}, socket) do
    {:noreply, put_flash(socket, type, message)}
  end

  @adjustment_kind_icon_names %{
    blue_line: "blue-line",
    bus: "mode-bus",
    commuter_rail: "mode-commuter-rail",
    green_line: "green-line",
    green_line_b: "green-line-b",
    green_line_c: "green-line-c",
    green_line_d: "green-line-d",
    green_line_e: "green-line-e",
    mattapan_line: "mattapan-line",
    orange_line: "orange-line",
    red_line: "red-line",
    silver_line: "silver-line"
  }

  defp adjustment_kind_icon_path(socket, kind) do
    Phoenix.VerifiedRoutes.static_path(
      socket,
      "/images/icon-#{@adjustment_kind_icon_names[kind]}-small.svg"
    )
  end

  defp icon_paths(socket) do
    Adjustment.kinds()
    |> Enum.map(&{&1, adjustment_kind_icon_path(socket, &1)})
    |> Enum.into(%{})
    |> Map.put(
      :subway,
      Phoenix.VerifiedRoutes.static_path(socket, "/images/icon-mode-subway-small.svg")
    )
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
end
