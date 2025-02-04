defmodule ArrowWeb.ReplacementServiceSection do
  @moduledoc """
  LiveComponent used by disruptions to show/create/edit/delete replacement_services
  """

  use ArrowWeb, :live_component

  import Phoenix.HTML.Form
  alias Phoenix.LiveView

  alias Arrow.Disruptions.{DisruptionV2, ReplacementService, ReplacementServiceUpload}
  alias Arrow.{Disruptions, Shuttles}
  alias ArrowWeb.ShapeView

  attr :id, :string
  attr :form, :any, required: true
  attr :disruption, DisruptionV2, required: true
  attr :replacement_service, ReplacementService
  attr :uploads, :any
  attr :source_workbook_data, :any
  attr :source_workbook_filename, :string

  def render(assigns) do
    ~H"""
    <div id={@id}>
      <h3>Replacement Services</h3>
      <%= if Ecto.assoc_loaded?(@disruption.replacement_services) and Enum.any?(@disruption.replacement_services) do %>
        <div class="mb-3">
          <.table id="replacement_services_table" rows={@disruption.replacement_services}>
            <:col :let={replacement_service_row} label="shuttle">
              {replacement_service_row.shuttle.shuttle_name}
            </:col>
            <:col :let={replacement_service_row} label="start date">
              {replacement_service_row.start_date}
            </:col>
            <:col :let={replacement_service_row} label="end date">
              {replacement_service_row.end_date}
            </:col>
            <:action :let={replacement_service_row}>
              <.button
                disabled={!is_nil(@form)}
                type="button"
                phx-click="edit_replacement_service"
                phx-value-replacement_service={replacement_service_row.id}
                phx-target={@myself}
              >
                <.icon name="hero-pencil-solid" class="bg-primary" />
              </.button>
              <.button
                disabled={!is_nil(@form)}
                type="button"
                phx-click="delete_replacement_service"
                phx-value-replacement_service={replacement_service_row.id}
                phx-target={@myself}
                data-confirm="Are you sure you want to delete this replacement_service?"
              >
                <.icon name="hero-trash-solid" class="bg-primary" />
              </.button>
            </:action>
          </.table>
        </div>
      <% end %>

      <.link_button
        :if={is_nil(@form)}
        id="add_replacement_service"
        class="btn-link"
        phx-click="add_replacement_service"
      >
        <.icon name="hero-plus" /> <span>add replacement_service component</span>
      </.link_button>

      <.simple_form
        :if={!is_nil(@form)}
        for={@form}
        id="replacement_service-form"
        phx-submit={@action}
        phx-change="validate"
        phx-target={@myself}
      >
        <input value={@disruption.id} type="hidden" name={input_name(@form, :disruption_id)} />
        <div class="container border-2 border-dashed border-primary p-3">
          <h4 class="text-primary">
            {if @action == "create",
              do: "add new replacement service component",
              else: "edit disruption replacement service component"}
          </h4>
          <.shuttle_input field={@form[:shuttle_id]} shuttle={input_value(@form, :shuttle)} />
          <div :if={not empty_input_value?(@form[:shuttle_id].value)} class="row">
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
                save component
              </.button>
            </div>
            <div class="col-lg-3">
              <.button
                type="button"
                id="cancel_add_replacement_service_button"
                class="btn-outline-primary btn-sm w-100"
                data-confirm="Are you sure you want to cancel? All changes to this replacement service component will be lost!"
                phx-click="cancel_add_replacement_service"
                phx-target={@myself}
              >
                cancel
              </.button>
            </div>
          </div>
        </div>
      </.simple_form>
    </div>
    """
  end

  def empty_input_value?("") do
    true
  end

  def empty_input_value?(nil) do
    true
  end

  def empty_input_value?(_) do
    false
  end

  def get_shuttle_map_props(shuttle_id) do
    %{layers: Shuttles.get_shuttle!(shuttle_id).routes |> ShapeView.routes_to_layers()}
  end

  def update(%{replacement_service: nil} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(form: nil)
     |> assign(action: "create")
     |> assign(errors: [])
     |> assign(source_workbook_data: nil)
     |> assign(source_workbook_filename: nil)
     |> allow_upload(:replacement_service,
       accept: ~w(.xlsx),
       progress: &handle_progress/3,
       auto_upload: true
     )}
  end

  def update(assigns, socket) do
    replacement_service = assigns.replacement_service
    form = replacement_service |> Disruptions.change_replacement_service() |> to_form()
    action = if is_nil(assigns.replacement_service.id), do: "create", else: "update"

    {:ok,
     socket
     |> assign(assigns)
     |> assign(form: form)
     |> assign(action: action)
     |> assign(errors: [])
     |> allow_upload(:replacement_service,
       accept: ~w(.xlsx),
       progress: &handle_progress/3,
       auto_upload: true
     )}
  end

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

  def handle_event("create", %{"replacement_service" => replacement_service_params}, socket) do
    case Disruptions.create_replacement_service(replacement_service_params) do
      {:ok, _} ->
        send(self(), :update_disruption)
        send(self(), {:put_flash, :info, "Replacement service created successfully"})

        {:noreply,
         socket
         |> assign(replacement_service: nil)
         |> assign(form: nil)}

      {:error, changeset} ->
        {:noreply,
         assign(socket,
           form: to_form(changeset)
         )}
    end
  end

  def handle_event("update", %{"replacement_service" => replacement_service_params}, socket) do
    replacement_service =
      Disruptions.get_replacement_service!(socket.assigns.replacement_service.id)

    case(
      Disruptions.update_replacement_service(
        replacement_service,
        replacement_service_params
      )
    ) do
      {:ok, _} ->
        send(self(), :update_disruption)
        send(self(), {:put_flash, :info, "Replacement Service updated successfully"})

        {:noreply,
         socket
         |> assign(replacement_service: nil)
         |> assign(form: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("cancel_add_replacement_service", _params, socket) do
    send(self(), :cancel_replacement_service_form)

    {:noreply,
     socket
     |> assign(replacement_service: nil)
     |> assign(form: nil)}
  end

  def handle_event("selection_recovery", _params, socket) do
    {:noreply, socket}
  end

  def handle_event(
        "edit_replacement_service",
        %{"replacement_service" => replacement_service_id},
        socket
      ) do
    {parsed_id, _} = Integer.parse(replacement_service_id)
    replacement_service = Disruptions.get_replacement_service!(parsed_id)

    {:noreply,
     socket
     |> assign(
       :form,
       replacement_service |> Disruptions.change_replacement_service() |> to_form()
     )
     |> assign(replacement_service: replacement_service)
     |> assign(action: "update")}
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
        send(self(), :update_disruption)
        send(self(), {:put_flash, :info, "Replacement service deleted successfully"})
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        send(self(), {:put_flash, :error, "Error when deleting replacement service!"})
        {:noreply, assign(socket, replacement_service: to_form(changeset))}
    end
  end

  def update_form_with_workbook_data(socket, data, client_name) do
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
      %LiveView.UploadEntry{client_name: client_name} = entry

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
