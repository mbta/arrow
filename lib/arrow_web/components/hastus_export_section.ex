defmodule ArrowWeb.HastusExportSection do
  @moduledoc """
  LiveComponent used by disruptions to upload HASTUS service schedules
  """

  use ArrowWeb, :live_component
  import Phoenix.HTML.Form

  alias Arrow.Hastus.{Export, ExportUpload}
  alias Phoenix.LiveView

  attr :id, :string
  attr :form, :any, required: true
  attr :uploads, :any
  attr :icon_paths, :map, required: true

  @route_icon_names %{
    "Blue" => :blue_line,
    "Green" => :green_line,
    "Orange" => :orange_line,
    "Red" => :red_line
  }

  def render(assigns) do
    ~H"""
    <section id={@id}>
      <h3>HASTUS Service Schedules</h3>
      <.link_button
        :if={is_nil(@form)}
        class="btn-link"
        phx-click="upload_hastus_export"
        id="upload-hastus-export-component"
      >
        <.icon name="hero-plus" /> <span>upload HASTUS export</span>
      </.link_button>

      <.simple_form
        :if={@show_upload_form}
        for={@form}
        id="upload-form"
        phx-submit={@action}
        phx-change="validate"
        phx-target={@myself}
      >
        <div class="container border-2 border-dashed border-primary p-3">
          <h4 class="text-primary">
            add a new service schedule
          </h4>
          <h5>Upload a new HASTUS export</h5>
          <div class="row">
            <div class="col-lg-3">
              <.link_button
                class="btn-primary btn-sm w-100"
                phx-click={JS.dispatch("click", to: "##{@uploads.hastus_export.ref}")}
                target="_blank"
              >
                <.live_file_input upload={@uploads.hastus_export} class="hidden" /> Upload HASTUS .zip
              </.link_button>
            </div>
            <div class="col-lg-3">
              <.button
                type="button"
                id="cancel_add_hastus_export_button"
                class="btn-outline-primary btn-sm w-100"
                phx-click="cancel_add_hastus_export"
                phx-target={@myself}
              >
                cancel
              </.button>
            </div>
          </div>
        </div>
      </.simple_form>

      <.simple_form
        :if={@show_service_import_form}
        for={@form}
        id="service-import-form"
        phx-submit={@action}
        phx-change="validate"
        phx-target={@myself}
      >
        <div class="container border-2 border-dashed border-primary p-3">
          <h4 class="text-primary mb-0">
            add a new service schedule
          </h4>
          <.input field={@form[:source_export_filename]} type="text" class="hidden" />
          <div class="text-success mb-3">
            <strong>
              <i>Successfully imported export {input_value(@form, :source_export_filename)}!</i>
            </strong>
          </div>
          <div class="row mb-3">
            <.input field={@form[:route_id]} type="text" class="hidden" />
            <div class="col-lg-2">
              <strong>route</strong>
            </div>
            <div class="col-lg-10">
              <span
                class="m-icon m-icon-sm mr-1"
                style={"background-image: url('#{route_icon_path(@icon_paths, input_value(@form, :route_id))}');"}
              />
              {input_value(@form, :route_id)} line
            </div>
          </div>
          <.inputs_for :let={f_service} field={@form[:services]}>
            <div class="row mb-3">
              <div class="col-lg-2">
                <strong>service ID</strong>
              </div>
              <div class="col-lg-10">
                {input_value(f_service, :service_id)}
              </div>
            </div>
            <div class="row">
              <div class="col-lg-2"></div>
              <div class="col-lg-2">
                <strong>import?</strong>
              </div>
              <div class="col-lg-4">
                <strong>start date</strong>
              </div>
              <div class="col-lg-4">
                <strong>end date</strong>
              </div>
            </div>
            <div class="row">
              <.inputs_for :let={f_date} field={f_service[:service_dates]}>
                <div class="col-lg-2"></div>
                <%= if f_date.index == 0 do %>
                  <div class="col-lg-2">
                    <.input field={f_service[:import?]} type="checkbox" />
                  </div>
                <% else %>
                  <div class="col-lg-2"></div>
                <% end %>
                <div class="col-lg-4">
                  <.input field={f_date[:start_date]} type="date" />
                </div>
                <div class="col-lg-4">
                  <.input field={f_date[:end_date]} type="date" />
                </div>
              </.inputs_for>
            </div>
          </.inputs_for>
        </div>
      </.simple_form>
    </section>
    """
  end

  def update(%{hastus_export: nil} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(form: nil)
     |> assign(action: "create")
     |> assign(show_upload_form: false)
     |> assign(show_service_import_form: false)
     |> allow_upload(:hastus_export,
       accept: ~w(.zip),
       progress: &handle_progress/3,
       auto_upload: true
     )}
  end

  def update(assigns, socket) do
    hastus_export = assigns.hastus_export
    form = hastus_export |> Export.changeset(%{}) |> to_form()
    action = if is_nil(assigns.hastus_export.id), do: "create", else: "update"

    {:ok,
     socket
     |> assign(assigns)
     |> assign(form: form)
     |> assign(action: action)
     |> assign(show_upload_form: true)
     |> assign(show_service_import_form: false)
     |> allow_upload(:hastus_export,
       accept: ~w(.zip),
       progress: &handle_progress/3,
       auto_upload: true
     )}
  end

  def handle_event("cancel_add_hastus_export", _params, socket) do
    send(self(), :cancel_hastus_export_form)

    {:noreply,
     socket
     |> assign(hastus_export: nil)
     |> assign(form: nil)}
  end

  def handle_event("validate", _, socket) do
    {:noreply, socket}
  end

  defp handle_progress(:hastus_export, entry, socket) do
    socket = clear_flash(socket)

    if entry.done? do
      %LiveView.UploadEntry{client_name: client_name} = entry

      case consume_uploaded_entry(
             socket,
             entry,
             &ExportUpload.extract_data_from_upload/1
           ) do
        {:error, error} ->
          send(self(), {:put_flash, :error, "Failed to upload from #{client_name}: #{error}"})
          {:noreply, socket}

        {:ok, data, route} ->
          form =
            socket.assigns.form.source
            |> Ecto.Changeset.put_change(:services, data)
            |> Ecto.Changeset.put_change(:route_id, route)
            |> Ecto.Changeset.put_change(:source_export_filename, client_name)
            |> to_form()

          {:noreply,
           assign(socket, form: form, show_upload_form: false, show_service_import_form: true)}
      end
    else
      {:noreply, socket}
    end
  end

  defp route_icon_path(icon_paths, route_id) do
    Map.get(icon_paths, @route_icon_names[route_id])
  end
end
