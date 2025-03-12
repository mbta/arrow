defmodule ArrowWeb.HastusExportSection do
  @moduledoc """
  LiveComponent used by disruptions to upload HASTUS service schedules
  """

  use ArrowWeb, :live_component
  import Phoenix.HTML.Form

  alias Arrow.Disruptions.DisruptionV2
  alias Arrow.Hastus
  alias Arrow.Hastus.{Export, ExportUpload}
  alias Phoenix.LiveView

  attr :id, :string
  attr :form, :any, required: true
  attr :uploads, :any
  attr :icon_paths, :map, required: true
  attr :error, :string
  attr :user_id, :string
  attr :uploaded_file_name, :string
  attr :disruption, DisruptionV2, required: true

  @line_icon_names %{
    "line-Blue" => :blue_line,
    "line-Green" => :green_line,
    "line-Orange" => :orange_line,
    "line-Red" => :red_line
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
          <div :if={not is_nil(@error)} class="text-danger">
            {@error}
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
          <.input field={@form[:s3_path]} type="text" class="hidden" />
          <.input field={@form[:disruption_id]} type="text" class="hidden" />
          <.input field={@form[:line_id]} type="text" class="hidden" />
          <div class="text-success mb-3">
            <strong>
              <i>Successfully imported export {@uploaded_file_name}!</i>
            </strong>
          </div>
          <div class="row mb-3">
            <.input field={@form[:line_id]} type="text" class="hidden" />
            <div class="col-lg-2">
              <strong>route</strong>
            </div>
            <div class="col-lg-10">
              <span
                class="m-icon m-icon-sm mr-1"
                style={"background-image: url('#{line_icon_path(@icon_paths, input_value(@form, :line_id))}');"}
              />
              {format_line_id(input_value(@form, :line_id))} line
            </div>
          </div>
          <.inputs_for :let={f_service} field={@form[:services]}>
            <.input field={f_service[:name]} type="text" class="hidden" />
            <div class="row mb-3">
              <div class="col-lg-2">
                <strong>service ID</strong>
              </div>
              <div class="col-lg-10">
                {input_value(f_service, :name)}
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
          <div class="row">
            <div class="col-lg-4">
              <.button type="submit" class="btn btn-primary btn-sm w-100" phx-target={@myself}>
                save
              </.button>
            </div>
            <div class="col-lg-3">
              <.button
                type="button"
                id="cancel_add_hastus_export_button"
                class="btn-outline-primary btn-sm w-100"
                data-confirm="Are you sure you want to cancel? All changes to this HASTUS export will be lost!"
                phx-click="cancel_add_hastus_export"
                phx-target={@myself}
              >
                cancel
              </.button>
            </div>
          </div>
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
     |> assign(error: nil)
     |> assign(uploaded_file_name: nil)
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
     |> assign(error: nil)
     |> assign(uploaded_file_name: nil)
     |> allow_upload(:hastus_export,
       accept: ~w(.zip),
       progress: &handle_progress/3,
       auto_upload: true
     )}
  end

  def handle_event("create", %{"export" => export_params}, socket) do
    case Hastus.create_export(export_params) do
      {:ok, _} ->
        send(self(), :update_disruption)
        send(self(), {:put_flash, :info, "HASTUS export created successfully"})

        {:noreply,
         socket
         |> assign(hastus_export: nil)
         |> assign(form: nil)
         |> assign(show_upload_form: false)
         |> assign(show_service_import_form: false)}

      {:error, changeset} ->
        {:noreply,
         assign(socket,
           form: to_form(changeset)
         )}
    end
  end

  def handle_event("cancel_add_hastus_export", _params, socket) do
    send(self(), :cancel_hastus_export_form)

    {:noreply,
     socket
     |> assign(hastus_export: nil)
     |> assign(form: nil)
     |> assign(show_upload_form: false)
     |> assign(show_service_import_form: false)}
  end

  def handle_event("validate", _, socket) do
    {:noreply, socket}
  end

  defp handle_progress(:hastus_export, entry, socket) do
    socket = socket |> clear_flash() |> assign(error: nil)

    if entry.done? do
      %LiveView.UploadEntry{client_name: client_name} = entry

      case consume_uploaded_entry(
             socket,
             entry,
             &ExportUpload.extract_data_from_upload(&1, socket.assigns.user_id)
           ) do
        {:error, error} ->
          {:noreply, assign(socket, error: error)}

        {:ok, data, line} ->
          form =
            socket.assigns.hastus_export
            |> Hastus.change_export(%{
              "services" => data,
              "line_id" => line,
              "s3_path" => client_name,
              "disruption_id" => socket.assigns.disruption.id
            })
            |> to_form(action: :validate)

          {:noreply,
           assign(socket,
             form: form,
             show_upload_form: false,
             show_service_import_form: true,
             uploaded_file_name: client_name
           )}
      end
    else
      {:noreply, socket}
    end
  end

  defp line_icon_path(icon_paths, line_id) do
    Map.get(icon_paths, @line_icon_names[line_id])
  end

  defp format_line_id(line_id), do: String.replace(line_id, "line-", "")
end
