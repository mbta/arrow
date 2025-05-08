defmodule ArrowWeb.EditReplacementServiceForm do
  @moduledoc false
  use ArrowWeb, :live_component

  import Phoenix.HTML.Form

  alias Arrow.Disruptions
  alias Arrow.Disruptions.DisruptionV2
  alias Arrow.Disruptions.ReplacementService
  alias Arrow.Disruptions.ReplacementServiceUpload
  alias Arrow.Shuttles
  alias ArrowWeb.ShapeView
  alias Phoenix.LiveView.UploadEntry

  attr :disruption, DisruptionV2, required: true
  attr :replacement_service, ReplacementService, required: true
  attr :icon_paths, :map, required: true

  def render(assigns) do
    ~H"""
    <div
      class="mt-3 overflow-hidden"
      style="display: none"
      phx-mounted={
        JS.show(transition: {"ease-in duration-300", "max-h-0", "max-h-screen"}, time: 300)
        |> JS.focus()
      }
      phx-remove={
        JS.hide(transition: {"ease-out duration-300", "max-h-screen", "max-h-0"}, time: 300)
      }
    >
      <.simple_form
        :if={!is_nil(@form)}
        for={@form}
        id="replacement_service-form"
        phx-submit="save"
        phx-change="validate"
        phx-target={@myself}
      >
        <input value={@disruption.id} type="hidden" name={input_name(@form, :disruption_id)} />
        <div class="container-fluid border-2 border-dashed border-primary p-3">
          <h4 class="text-primary">
            {if !@replacement_service.id,
              do: "add new replacement service component",
              else: "edit disruption replacement service component"}
          </h4>
          <.shuttle_input
            field={@form[:shuttle_id]}
            shuttle={input_value(@form, :shuttle)}
            only_approved?={true}
          />
          <div :if={not empty_input_value?(@form[:shuttle_id].value)} class="row relative z-0">
            <div class="col p-0">
              {live_react_component(
                "Components.ShapeStopViewMap",
                get_shuttle_map_props(@form[:shuttle_id].value),
                id: "shuttle-view-map-disruptionsv2"
              )}
            </div>
          </div>
          <div class="row">
            <div class="col-lg-6">
              <.input
                field={@form[:source_workbook_filename]}
                type="text"
                label="filename"
                disabled={true}
                id="display_replacement_service_source_workbook_filename"
              />
              <.input field={@form[:source_workbook_filename]} type="text" class="hidden" />
              <div class="form-group">
                <.link_button
                  class="btn-primary btn-sm"
                  phx-click={JS.dispatch("click", to: "##{@uploads.replacement_service.ref}")}
                  target="_blank"
                >
                  <.live_file_input upload={@uploads.replacement_service} class="hidden" />
                  Upload Replacement Service XLSX
                </.link_button>
                <.input field={@form[:source_workbook_data]} type="text" class="hidden" />
              </div>
            </div>
            <.input field={@form[:reason]} type="text" label="reason" class="col-lg-4" />
          </div>
          <div class="row">
            <.input field={@form[:start_date]} type="date" label="start date" class="col-lg-4" />
            <.input field={@form[:end_date]} type="date" label="end date" class="col-lg-4" />
          </div>
          <div class="row">
            <div class="col p-0">
              <%= if not Enum.empty?(@errors) do %>
                <div :for={{message, errors} <- @errors}>
                  <aside role="alert" class="alert alert-danger">
                    <h4 class="alert-heading">{message}</h4>
                    <ul :for={{tab, error} <- errors}>
                      <%= if is_list(error) do %>
                        <li>{tab}</li>
                        <ul>
                          <%= for suberror <- error do %>
                            <li>{suberror}</li>
                          <% end %>
                        </ul>
                      <% else %>
                        <li>{tab}: {error}</li>
                      <% end %>
                    </ul>
                  </aside>
                </div>
              <% end %>
            </div>
          </div>
          <div class="row">
            <div class="col-lg-4">
              <.button
                disabled={not Enum.empty?(@errors)}
                type="submit"
                class="btn btn-primary btn-sm w-100"
                phx-target={@myself}
              >
                Save component
              </.button>
            </div>
            <div class="col-lg-3">
              <.link
                id="cancel_add_replacement_service_button"
                class="btn btn-outline-primary btn-sm w-100"
                data-confirm="Are you sure you want to cancel? All changes to this replacement service component will be lost!"
                patch={~p"/disruptions/#{@disruption.id}"}
              >
                Cancel
              </.link>
            </div>
          </div>
        </div>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    form = assigns.replacement_service |> Disruptions.change_replacement_service() |> to_form()

    socket =
      socket
      |> assign(assigns)
      |> assign(:errors, [])
      |> assign(:form, form)
      |> allow_upload(:replacement_service,
        accept: ~w(.xlsx),
        progress: &handle_progress/3,
        auto_upload: true
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"replacement_service" => replacement_service_params}, socket) do
    form =
      socket.assigns.replacement_service
      |> Disruptions.change_replacement_service(%{
        replacement_service_params
        | "disruption_id" => socket.assigns.disruption.id
      })
      |> to_form(action: :validate)

    {:noreply, assign(socket, form: form, errors: [])}
  end

  def handle_event("save", %{"replacement_service" => replacement_service_params}, socket) do
    if socket.assigns.replacement_service.id do
      update_replacement_service(replacement_service_params, socket)
    else
      create_replacement_service(replacement_service_params, socket)
    end
  end

  defp create_replacement_service(replacement_service_params, socket) do
    case Disruptions.create_replacement_service(replacement_service_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> push_patch(to: ~p"/disruptions/#{socket.assigns.disruption.id}")
         |> put_flash(:info, "Replacement service created successfully")}

      {:error, changeset} ->
        {:noreply,
         assign(socket,
           form: to_form(changeset)
         )}
    end
  end

  defp update_replacement_service(replacement_service_params, socket) do
    replacement_service =
      Disruptions.get_replacement_service!(socket.assigns.replacement_service.id)

    case(
      Disruptions.update_replacement_service(
        replacement_service,
        replacement_service_params
      )
    ) do
      {:ok, _} ->
        {:noreply,
         socket
         |> push_patch(to: ~p"/disruptions/#{socket.assigns.disruption.id}")
         |> put_flash(:info, "Replacement service updated successfully")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp get_shuttle_map_props(shuttle_id) do
    %{layers: Shuttles.get_shuttle!(shuttle_id).routes |> ShapeView.routes_to_layers()}
  end

  defp empty_input_value?("") do
    true
  end

  defp empty_input_value?(nil) do
    true
  end

  defp empty_input_value?(_) do
    false
  end

  defp update_form_with_workbook_data(socket, data, client_name) do
    case Jason.encode_to_iodata(data) do
      {:ok, iodata} ->
        changeset = socket.assigns.form.source

        changeset =
          changeset
          |> Ecto.Changeset.put_change(:source_workbook_data, iodata)
          |> Ecto.Changeset.put_change(:source_workbook_filename, client_name)

        socket =
          socket
          |> put_flash(:info, "Successfully uploaded replacement service workbook")
          |> assign(form: to_form(changeset, action: :validate))

        {:noreply, socket}

      {:error, error} ->
        {:error, [{"Data encoding failed", error}]}
    end
  end

  defp handle_progress(:replacement_service, entry, socket) do
    socket = socket |> clear_flash() |> assign(errors: [])

    if entry.done? do
      %UploadEntry{client_name: client_name} = entry

      case consume_uploaded_entry(
             socket,
             entry,
             &ReplacementServiceUpload.extract_data_from_upload/1
           ) do
        {:error, errors} ->
          {:noreply, assign(socket, errors: [{"Failed to upload from #{client_name}", errors}])}

        {:ok, data} ->
          update_form_with_workbook_data(socket, data, client_name)
      end
    else
      {:noreply, socket}
    end
  end
end
