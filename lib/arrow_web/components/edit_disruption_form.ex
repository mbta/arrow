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
    <div
      class="overflow-hidden"
      style="display: none"
      phx-mounted={
        JS.show(
          transition: {"ease-out duration-300", "opacity-0 max-h-0", "opacity-100 max-h-screen"},
          time: 300
        )
      }
      phx-remove={
        JS.hide(
          transition: {"ease-out duration-300", "opacity-100 max-h-screen", "opacity-0 max-h-0"},
          time: 300
        )
      }
    >
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
              <% approved? = normalize_value("checkbox", input_value(@form, :status)) %>
              <legend>Approval Status</legend>
              <div
                :for={{{value, status}, idx} <- Enum.with_index(status_labels())}
                class={[
                  "form-check",
                  input_value(@form, :status) == value && @form[:status].errors != [] && "is-invalid"
                ]}
              >
                <input
                  name={@form[:status].name}
                  id={"#{@form[:status].id}-#{idx}"}
                  class="form-check-input"
                  type="radio"
                  checked={input_value(@form, :status) == value}
                  value={value}
                />
                <label for={"#{@form[:status].id}-#{idx}"} class="form-check-label">
                  {status}
                </label>
              </div>
              <.error :for={error <- @form[:status].errors}>
                {translate_error(error)}
              </.error>
            </fieldset>
          <% end %>
        </div>
        <fieldset>
          <legend>Mode</legend>
          <div
            :for={{{value, mode}, idx} <- Enum.with_index(mode_labels())}
            class={[
              "form-check",
              input_value(@form, :mode) == value && @form[:mode].errors != [] && "is-invalid"
            ]}
          >
            <input
              name={@form[:mode].name}
              id={"#{@form[:mode].id}-#{idx}"}
              class="form-check-input"
              type="radio"
              checked={input_value(@form, :mode) == value}
              disabled={value not in [:subway, :commuter_rail]}
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
          <.error :for={error <- @form[:mode].errors}>
            {translate_error(error)}
          </.error>
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
              Save disruption
            </.button>
          </div>
          <div class="w-25 mr-2">
            <.link
              patch={if @disruption.id, do: ~p"/disruptions/#{@disruption.id}", else: ~p"/"}
              class="btn btn-outline-primary w-100"
              data-confirm="Are you sure you want to cancel? All changes will be lost!"
            >
              Cancel
            </.link>
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
    # if the disruption lacks a mode (in which case it's a new disruption), default to subway,
    # otherwise leave the value unchanged
    changeset =
      if assigns[:disruption].mode do
        Disruptions.change_disruption_v2(assigns[:disruption])
      else
        Disruptions.change_disruption_v2(assigns[:disruption], %{mode: :subway})
      end

    socket =
      assign(socket,
        form: to_form(changeset),
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
    params = Map.put(params, "status", :pending)

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
