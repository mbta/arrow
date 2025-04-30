defmodule ArrowWeb.EditDisruptionForm do
  @moduledoc false
  use ArrowWeb, :live_component

  alias Arrow.Disruptions
  alias Arrow.Disruptions.DisruptionV2

  import Phoenix.HTML.Form

  attr :disruption, DisruptionV2, required: true
  attr :icon_paths, :map, required: true

  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="disruption_v2-form"
        phx-submit="save"
        phx-change="validate"
        phx-target={@myself}
      >
        <div class="flex flex-row">
          <fieldset class="w-50">
            <legend>Title</legend>
            <.input field={@form[:title]} type="text" placeholder="Add text" />
          </fieldset>
          <%= if @disruption.id do %>
            <fieldset class="w-50 ml-20">
              <legend>Approval Status</legend>
              <div class="form-check">
                <input
                  name={@form[:is_active].name}
                  id="status-approved"
                  class="form-check-input"
                  type="radio"
                  checked={normalize_value("checkbox", input_value(@form, :is_active))}
                  value="true"
                />
                <label for="status-approved" class="form-check-label">
                  Approved
                </label>
              </div>
              <div class="form-check">
                <input
                  name={@form[:is_active].name}
                  id="status-pending"
                  class="form-check-input"
                  type="radio"
                  checked={!normalize_value("checkbox", input_value(@form, :is_active))}
                  value="false"
                />
                <label for="status-pending" class="form-check-label">
                  Pending
                </label>
              </div>
            </fieldset>
          <% end %>
        </div>
        <fieldset>
          <legend>Mode</legend>
          <div :for={{{value, mode}, idx} <- Enum.with_index(mode_labels())} class="form-check">
            <input
              name={@form[:mode].name}
              id={"#{@form[:mode].id}-#{idx}"}
              class="form-check-input"
              type="radio"
              checked={input_value(@form, :mode) == value}
              disabled={value != :subway}
              value={value}
            />
            <label for={"#{@form[:mode].id}-#{idx}"} class="form-check-label">
              <span
                class="m-icon m-icon-sm mr-1"
                style={"background-image: url('#{Map.get(@icon_paths, value)}');"}
              >
              </span>
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
            aria-label="description"
          />

          <small id="descriptionHelp" class="form-text">
            please include: types of disruption, place, and reason
          </small>
        </fieldset>
        <div class="d-flex justify-content-center py-4 mb-5">
          <div class="w-25 mr-2">
            <.button type="submit" class="btn btn-primary w-100" form="disruption_v2-form">
              save disruption
            </.button>
          </div>
          <div class="w-25 mr-2">
            <!-- #TODO: return to viewing disruption if editing -->
            <.link_button
              href={~p"/"}
              class="btn-outline-primary w-100"
              data-confirm="Are you sure you want to cancel? All changes will be lost!"
            >
              cancel
            </.link_button>
          </div>
        </div>
      </.simple_form>
    </div>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    socket =
      assign(socket,
        form:
          assigns[:disruption]
          |> Disruptions.change_disruption_v2(%{is_active: false, mode: :subway})
          |> to_form(),
        icon_paths: assigns[:icon_paths],
        disruption: assigns[:disruption]
      )

    {:ok, socket}
  end

  def handle_event(
        "validate",
        %{"disruption_v2" => disruption_v2_params},
        socket
      ) do
    form =
      socket.assigns.disruption
      |> Disruptions.change_disruption_v2(disruption_v2_params)
      |> to_form(action: :validate)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"disruption_v2" => disruption_v2_params}, socket) do
    disruption_id = socket.assigns.disruption.id

    if disruption_id do
      update_disruption(disruption_v2_params, socket)
    else
      create_disruption(disruption_v2_params, socket)
    end
  end

  defp create_disruption(params, socket) do
    params = Map.put(params, "is_active", false)

    case Disruptions.create_disruption_v2(params) do
      {:ok, disruption} ->
        socket =
          socket
          |> put_flash(:info, "Disruption created successfully")
          |> push_patch(to: ~p"/disruptions/#{disruption.id}")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket =
          socket
          |> put_flash(:error, "Error creating disruption")
          |> assign(:form, to_form(changeset))

        {:noreply, socket}
    end
  end

  defp update_disruption(params, socket) do
    case Disruptions.update_disruption_v2(socket.assigns.disruption, params) do
      {:ok, disruption} ->
        socket =
          socket
          |> put_flash(:info, "Disruption updated successfully")
          |> push_patch(to: ~p"/disruptions/#{disruption.id}")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket =
          socket
          |> put_flash(:error, "Error updating disruption")
          |> assign(:form, to_form(changeset))

        {:noreply, socket}
    end
  end
end
