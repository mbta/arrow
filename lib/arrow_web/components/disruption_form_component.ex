defmodule ArrowWeb.DisruptionFormComponent do
  use ArrowWeb, :live_component
  import ArrowWeb.Flash, only: [put_flash!: 3]

  alias Arrow.Disruptions

  @impl true
  def render(assigns) do
    dbg()
    row_status_labels = %{"Approved": true, "Pending": false}
    mode_labels = %{"Subway": :subway, "Commuter Rail": :commuter_rail, "Bus": :bus, "Silver Line": :silver_line}
    ~H"""
    <div class="w-75">
      <.simple_form
        for={@form}
        id="disruption_v2-form"
        phx-target={@myself}
        phx-submit="save"
        phx-change="validate"
      >
        <div class="flex flex-row">
          <fieldset class="w-50">
            <legend>Title</legend>
            <.input field={@form[:title]} type="text" placeholder="Add text" />
          </fieldset>
          <fieldset class="w-50 ml-20">
            <legend>Approval Status</legend>
            <div :for={{{status, value}, idx} <- Enum.with_index(row_status_labels)}%>
              <label class="form-check form-check-label">
                <input
                  name={@form[:is_active].name}
                  id={"#{@form[:is_active].id}-#{idx}"}
                  class="form-check-input"
                  type="radio"
                  checked={to_string(@form[:is_active].value) == to_string(value)}
                  value={to_string(value)}
                />
                {status}
              </label>
            </div>
          </fieldset>
        </div>
        <fieldset>
          <legend>Mode</legend>
          <div :for={{{mode, value}, idx} <- Enum.with_index(mode_labels) }>
            <label class="form-check form-check-label">
              <input
                name={@form[:mode].name}
                id={"#{@form[:mode].id}-#{idx}"}
                class="form-check-input"
                type="radio"
                checked={@form[:mode].value == to_string(value)}
                value={to_string(value)}
              />

              <span
                class="m-icon m-icon-sm mr-1"
                style={"background-image: url('#{Map.get(@icon_paths, value)}');"}}
              ></span>
              {mode}
            </label>
          </div>
        </fieldset>
        <fieldset>
         <legend>Description</legend> 
          <.input
            type="textarea"
            class="form-control"
            cols={30}
            field={@form[:description]}
            aria-describedby="descriptionHelp"
            aria-label="description" />

          <small id="descriptionHelp" class="form-text">
            please include: types of disruption, place, and reason
          </small>
        </fieldset>
          
        <:actions>

        <div class="w-25 mr-2">
          <.button disabled={not Enum.empty?(@form.source.errors)} class="btn btn-primary w-100">Save Disruption</.button>
        </div>
        <div class="w-25 mr-2">
          <.link_button
            href={~p"/"}
            class="btn-outline-primary w-100"
            data-confirm="Are you sure you want to cancel? All changes will be lost!"
          >
            Cancel
          </.link_button>
        </div>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def handle_event("validate", %{"disruption_v2" => disruption_v2_params}, %Phoenix.LiveView.Socket{} = socket) do
      form = 
        socket.assigns.disruption_v2
        |> Disruptions.change_disruption_v2(disruption_v2_params) 
        |> to_form(action: :validate)

      {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("save", %{"disruption_v2" => disruption_v2_params}, socket) do
    save_disruption_v2(socket, socket.assigns.action, disruption_v2_params)
  end

  defp save_disruption_v2(socket, :edit, disruption_v2_params) do
    case Disruptions.update_disruption_v2(socket.assigns.disruption_v2, disruption_v2_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash!(:info, "Disruption edited successfully")}


      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_disruption_v2(socket, :create, disruption_v2_params) do
    case Disruptions.create_disruption_v2(disruption_v2_params) do
      {:ok, _} ->

        {:noreply,
         socket
         |> put_flash!(:info, "Disruption created successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

end
