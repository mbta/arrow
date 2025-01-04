defmodule ArrowWeb.DisruptionV2ViewLive do
  use ArrowWeb, :live_view

  alias Arrow.Disruptions
  alias Arrow.Disruptions.DisruptionV2
  alias Arrow.Adjustment

  embed_templates "disruption_v2_live/*"

  @impl true
  def mount(%{} = _params, _session, socket) do

    socket =
      socket
      |> assign(:form_action, "create")
      |> assign(:http_action, ~p"/disruptionsv2/new")
      |> assign(:title, "Create new Disruption")
      |> assign(:form, Disruptions.change_disruption_v2(%DisruptionV2{}) |> to_form)
      |> assign(:errors, %{})
      |> assign(:icon_paths, icon_paths(socket))
      |> assign(:disruption_v2, %DisruptionV2{})

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
    Phoenix.VerifiedRoutes.static_path(socket, "/images/icon-#{@adjustment_kind_icon_names[kind]}-small.svg")
  end

  defp icon_paths(socket) do
    Adjustment.kinds()
    |> Enum.map(&{&1, adjustment_kind_icon_path(socket, &1)})
    |> Enum.into(%{})
    |> Map.put(:subway, Phoenix.VerifiedRoutes.static_path(socket, "/images/icon-mode-subway-small.svg"))
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
