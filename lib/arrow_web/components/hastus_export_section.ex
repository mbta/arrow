defmodule ArrowWeb.HastusExportSection do
  @moduledoc """
  LiveComponent used by disruptions to upload HASTUS service schedules
  """

  use ArrowWeb, :live_component

  alias Arrow.Disruptions.{DisruptionV2, HastusExport, HastusExportUpload}
  alias Phoenix.LiveView

  attr :id, :string
  attr :form, :any, required: true
  attr :uploads, :any
  attr :disruption, DisruptionV2, required: true
  attr :source_export_data, :any
  attr :source_export_filename, :any

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
        :if={!is_nil(@form)}
        for={@form}
        id="hastus_export-form"
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
    </section>
    """
  end

  def update(%{hastus_export: nil} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(form: nil)
     |> assign(action: "create")
     |> assign(errors: [])
     |> assign(source_export_data: nil)
     |> assign(source_export_filename: nil)
     |> allow_upload(:hastus_export,
       accept: ~w(.zip),
       progress: &handle_progress/3,
       auto_upload: true
     )}
  end

  def update(assigns, socket) do
    hastus_export = assigns.hastus_export
    form = hastus_export |> HastusExport.changeset(%{}) |> to_form()
    action = if is_nil(assigns.hastus_export.id), do: "create", else: "update"

    {:ok,
     socket
     |> assign(assigns)
     |> assign(form: form)
     |> assign(action: action)
     |> assign(errors: [])
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
    socket = socket |> clear_flash() |> assign(errors: [])

    if entry.done? do
      %LiveView.UploadEntry{client_name: client_name} = entry

      case consume_uploaded_entry(
             socket,
             entry,
             &HastusExportUpload.extract_data_from_upload/1
           ) do
        {:errors, errors} ->
          send(self(), {:put_flash, :errors, {"Failed to upload from #{client_name}:", errors}})
          {:noreply, socket}

        {:ok, data} ->
          {:noreply, socket}
          # update_form_with_workbook_data(socket, data, client_name)
      end
    else
      {:noreply, socket}
    end
  end
end
