defmodule ArrowWeb.DisruptionV2Live.DisruptionFormComponent do
  use ArrowWeb, :live_component

  alias Arrow.Disruptions
  alias Arrow.Adjustment

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

  @spec adjustment_kind_icon_path(Phoenix.LiveView.Socket, atom()) :: String.t()
  def adjustment_kind_icon_path(socket, kind) do
    Phoenix.VerifiedRoutes.static_path(socket, "/images/icon-#{@adjustment_kind_icon_names[kind]}-small.svg")
  end

  defp icon_paths(socket) do
    Adjustment.kinds()
    |> Enum.map(&{&1, adjustment_kind_icon_path(socket, &1)})
    |> Enum.into(%{})
    |> Map.put(:subway, Phoenix.VerifiedRoutes.static_path(socket, "/images/icon-mode-subway-small.svg"))
  end

  @impl true
  def render(%{socket: socket} = assigns) do

    row_status_labels = %{"Approved": true, "Pending": false}
    mode_labels = %{"Subway": :subway, "Commuter Rail": :commuter_rail, "Bus": :bus, "Silver Line": :silver_line}
    icon_paths = icon_paths(socket)
    ~H"""
    <div class="w-75">
      <.simple_form
        for={@form}
        id="disruption_v2-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div class="flex flex-row">
          <fieldset class="w-50">
            <legend>Title</legend>
            <.input field={@form[:name]} type="text" />
          </fieldset>
          <fieldset class="w-50 ml-20">
            <legend>Approval Status</legend>
            <%= for {status, value} <- row_status_labels do %>
              <label class="form-check form-check-label">
                <input
                  class="form-check-input"
                  type="radio"
                  name="revision[row_approved]"
                  value={to_string(value)}
                />
                {status}
              </label>
            <% end %>
          </fieldset>
        </div>
        <fieldset>
          <legend>Mode</legend>
          <%= for {mode, value} <- mode_labels do %>
            <label class="form-check form-check-label">
              <input
                class="form-check-input"
                type="radio"
                name="mode"
                checked={mode === value}
              />

              <span
                class="m-icon m-icon-sm mr-1"
                style={"background-image: url('#{Map.get(icon_paths, value)}');"}}
              ></span>

              {mode}

            </label>
          <% end %>
        </fieldset>
        <fieldset>
         <legend>Description</legend> 
          <textarea
            class="form-control"
            cols={30}
            name="revision[description]"
            aria-describedby="descriptionHelp"
            aria-label="description"
            required
          />
          <small id="descriptionHelp" class="form-text">
            please include: types of disruption, place, and reason
          </small>
        </fieldset>
        
        <:actions>
          <.button phx-disable-with="Saving...">Save Disruption v2</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{disruption_v2: disruption_v2} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Disruptions.change_disruption_v2(disruption_v2))
     end)}
  end

  @impl true
  def handle_event("validate", %{"disruption_v2" => disruption_v2_params}, socket) do
    changeset = Disruptions.change_disruption_v2(socket.assigns.disruption_v2, disruption_v2_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"disruption_v2" => disruption_v2_params}, socket) do
    save_disruption_v2(socket, socket.assigns.action, disruption_v2_params)
  end

  defp save_disruption_v2(socket, :edit, disruption_v2_params) do
    case Disruptions.update_disruption_v2(socket.assigns.disruption_v2, disruption_v2_params) do
      {:ok, disruption_v2} ->
        notify_parent({:saved, disruption_v2})

        {:noreply,
         socket
         |> put_flash(:info, "Disruption v2 updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_disruption_v2(socket, :new, disruption_v2_params) do
    case Disruptions.create_disruption_v2(disruption_v2_params) do
      {:ok, disruption_v2} ->
        notify_parent({:saved, disruption_v2})

        {:noreply,
         socket
         |> put_flash(:info, "Disruption v2 created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
