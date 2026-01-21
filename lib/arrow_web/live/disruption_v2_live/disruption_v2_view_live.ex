defmodule ArrowWeb.DisruptionV2ViewLive do
  use ArrowWeb, :live_view

  alias Arrow.{Disruptions, Limits}
  alias Arrow.Disruptions.{DisruptionV2, Limit, ReplacementService}
  alias Arrow.Hastus
  alias Arrow.Hastus.Export, as: HastusExport
  alias Arrow.Trainsformer.Export, as: TrainsformerExport
  alias Arrow.Trainsformer
  alias ArrowWeb.DisruptionComponents

  @impl true
  def render(assigns) do
    ~H"""
    <.navbar page={~p"/disruptions/new"} />

    <hr />

    <.header>
      {@title}
    </.header>

    <hr />

    <h2>Disruption</h2>
    <div>
      <%= if @disruption == @editing do %>
        <.live_component
          id="disruption_form"
          module={ArrowWeb.EditDisruptionForm}
          icon_paths={@icon_paths}
          disruption={@editing}
        />
      <% else %>
        <DisruptionComponents.view_disruption
          disruption={@disruption}
          icon_paths={@icon_paths}
          editing={@editing}
        />
      <% end %>
    </div>

    <%= if !@editing || !is_struct(@editing, DisruptionV2) || @editing.id do %>
      <%= if @disruption.mode != :commuter_rail do %>
        <DisruptionComponents.view_limits
          disruption={@disruption}
          icon_paths={@icon_paths}
          editing={@editing}
        />
      <% end %>

      <%= if @disruption.mode == :commuter_rail do %>
        <DisruptionComponents.view_trainsformer_service_schedules
          disruption={@disruption}
          editing={@editing}
          user_id={@user_id}
          icon_paths={@icon_paths}
        />
      <% else %>
        <DisruptionComponents.view_hastus_service_schedules
          disruption={@disruption}
          icon_paths={@icon_paths}
          editing={@editing}
          user_id={@user_id}
        />
      <% end %>

      <%= if @disruption.mode != :commuter_rail do %>
        <DisruptionComponents.view_replacement_services
          disruption={@disruption}
          icon_paths={@icon_paths}
          editing={@editing}
        />
      <% end %>
    <% end %>
    """
  end

  @impl true
  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign(:icon_paths, Arrow.Util.icon_paths(socket))
     |> assign(:user_id, session["current_user"].id)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("delete_limit", %{"limit" => limit_id}, socket) do
    {parsed_id, _} = Integer.parse(limit_id)
    limit = Limits.get_limit!(parsed_id)

    case Limits.delete_limit(limit) do
      {:ok, _} ->
        disruption = %{
          socket.assigns.disruption
          | limits: Enum.reject(socket.assigns.disruption.limits, &(&1.id == parsed_id))
        }

        {:noreply,
         socket
         |> assign(:disruption, disruption)
         |> put_flash(:info, "Limit deleted successfully")}

      {:error, %Ecto.Changeset{} = _changeset} ->
        {:noreply, socket |> put_flash(:error, "Error when deleting limit!")}
    end
  end

  def handle_event("delete_export", %{"export" => export_id}, socket) do
    {parsed_id, _} = Integer.parse(export_id)
    export = Hastus.get_export!(parsed_id)

    case Hastus.delete_export(export) do
      {:ok, _} ->
        disruption = %{
          socket.assigns.disruption
          | hastus_exports:
              Enum.reject(socket.assigns.disruption.hastus_exports, &(&1.id == parsed_id))
        }

        {:noreply,
         socket
         |> assign(:disruption, disruption)
         |> put_flash(:info, "Export deleted successfully")}

      {:error, %Ecto.Changeset{} = _changeset} ->
        {:noreply, put_flash(socket, :error, "Error when deleting export!")}
    end
  end

  def handle_event("delete_trainsformer_export", %{"export" => export_id}, socket) do
    dbg()
    {parsed_id, _} = Integer.parse(export_id)
    export = Trainsformer.get_export!(parsed_id)

    case Trainsformer.delete_export(export) do
      {:ok, _} ->
        disruption = %{
          socket.assigns.disruption
          | trainsformer_exports:
              Enum.reject(socket.assigns.disruption.trainsformer_exports, &(&1.id == parsed_id))
        }

        {:noreply,
         socket
         |> assign(:disruption, disruption)
         |> put_flash(:info, "Export deleted successfully")}

      {:error, %Ecto.Changeset{} = _changeset} ->
        {:noreply, put_flash(socket, :error, "Error when deleting export!")}
    end
  end

  def handle_event(
        "delete_replacement_service",
        %{"replacement_service" => replacement_service_id},
        socket
      ) do
    {parsed_id, _} = Integer.parse(replacement_service_id)
    replacement_service = Disruptions.get_replacement_service!(parsed_id)

    case Disruptions.delete_replacement_service(replacement_service) do
      {:ok, _} ->
        disruption = %{
          socket.assigns.disruption
          | replacement_services:
              Enum.reject(socket.assigns.disruption.replacement_services, &(&1.id == parsed_id))
        }

        {:noreply,
         socket
         |> assign(:disruption, disruption)
         |> put_flash(:info, "Replacement service deleted successfully")}

      {:error, %Ecto.Changeset{} = _changeset} ->
        {:noreply, put_flash(socket, :error, "Error when deleting replacement service!")}
    end
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    socket
    |> assign(:page_title, "Show Disruption v2")
    |> assign(:title, "view disruption")
    |> assign(:disruption, Disruptions.get_disruption_v2!(id))
    |> assign(:editing, false)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    disruption = Disruptions.get_disruption_v2!(id)

    socket
    |> assign(:title, "edit disruption")
    |> assign(:page_title, "Edit Disruption v2")
    |> assign(:disruption, disruption)
    |> assign(:editing, disruption)
  end

  defp apply_action(socket, :new, _params) do
    disruption = %DisruptionV2{}

    socket
    |> assign(:page_title, "New Disruption v2")
    |> assign(:title, "create disruption")
    |> assign(:disruption, disruption)
    |> assign(:editing, disruption)
  end

  defp apply_action(socket, :new_limit, %{"id" => id}) do
    disruption = Disruptions.get_disruption_v2!(id)

    socket
    |> assign(:title, "edit disruption")
    |> assign(:page_title, "Edit Disruption v2")
    |> assign(:disruption, disruption)
    |> assign(:editing, Limit.new(disruption_id: disruption.id))
  end

  defp apply_action(socket, :edit_limit, %{"id" => id, "limit_id" => limit_id}) do
    disruption = Disruptions.get_disruption_v2!(id)
    limit = Limits.get_limit!(limit_id)

    socket
    |> assign(:title, "edit disruption")
    |> assign(:page_title, "Edit Disruption v2")
    |> assign(:disruption, disruption)
    |> assign(:editing, limit)
  end

  defp apply_action(socket, :duplicate_limit, %{"id" => id, "limit_id" => limit_id}) do
    disruption = Disruptions.get_disruption_v2!(id)
    limit = limit_id |> Limits.get_limit!() |> Map.put(:id, nil)

    socket
    |> assign(:title, "edit disruption")
    |> assign(:page_title, "Edit Disruption v2")
    |> assign(:disruption, disruption)
    |> assign(:editing, limit)
  end

  defp apply_action(socket, :new_hastus_export, %{"id" => id}) do
    disruption = Disruptions.get_disruption_v2!(id)
    hastus_export = %HastusExport{services: []}

    socket
    |> assign(:title, "edit disruption")
    |> assign(:page_title, "Edit Disruption v2")
    |> assign(:disruption, disruption)
    |> assign(:editing, hastus_export)
  end

  defp apply_action(socket, :edit_hastus_export, %{"id" => id, "export_id" => export_id}) do
    disruption = Disruptions.get_disruption_v2!(id)
    hastus_export = Hastus.get_export!(export_id)

    socket
    |> assign(:title, "edit disruption")
    |> assign(:page_title, "Edit Disruption v2")
    |> assign(:disruption, disruption)
    |> assign(:editing, hastus_export)
  end

  defp apply_action(socket, :new_trainsformer_export, %{"id" => id}) do
    disruption = Disruptions.get_disruption_v2!(id)
    trainsformer_export = %TrainsformerExport{}

    socket
    |> assign(:title, "edit disruption")
    |> assign(:page_title, "Edit Disruption v2")
    |> assign(:disruption, disruption)
    |> assign(:editing, trainsformer_export)
  end

  defp apply_action(socket, :edit_trainsformer_export, %{"id" => id, "export_id" => export_id}) do
    disruption = Disruptions.get_disruption_v2!(id)
    trainsformer_export = Trainsformer.get_export!(export_id)

    socket
    |> assign(:title, "edit disruption")
    |> assign(:page_title, "Edit Disruption v2")
    |> assign(:disruption, disruption)
    |> assign(:editing, trainsformer_export)
  end

  defp apply_action(socket, :new_replacement_service, %{"id" => id}) do
    disruption = Disruptions.get_disruption_v2!(id)
    replacement_service = %ReplacementService{disruption_id: disruption.id}

    socket
    |> assign(:title, "edit disruption")
    |> assign(:page_title, "Edit Disruption v2")
    |> assign(:disruption, disruption)
    |> assign(:editing, replacement_service)
  end

  defp apply_action(socket, :edit_replacement_service, %{
         "id" => id,
         "replacement_service_id" => replacement_service_id
       }) do
    disruption = Disruptions.get_disruption_v2!(id)
    replacement_service = Disruptions.get_replacement_service!(replacement_service_id)

    socket
    |> assign(:title, "edit disruption")
    |> assign(:page_title, "Edit Disruption v2")
    |> assign(:disruption, disruption)
    |> assign(:editing, replacement_service)
  end
end
