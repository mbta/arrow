defmodule ArrowWeb.EditTrainsformerExportForm do
  @moduledoc false
  use ArrowWeb, :live_component

  alias Arrow.Disruptions.DisruptionV2
  alias Arrow.Trainsformer
  alias Arrow.Trainsformer.Export
  alias Arrow.Trainsformer.ExportUpload
  alias Phoenix.LiveView.UploadEntry

  attr :disruption, DisruptionV2, required: true
  attr :export, Export, required: true
  attr :user_id, :string, required: true

  @impl true
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
        :if={@show_upload_form}
        for={@form}
        id="upload-form"
        phx-submit="save"
        phx-change="validate"
        phx-target={@myself}
      >
        <div class="container-fluid border-2 border-dashed border-primary p-3">
          <h4 class="text-primary">
            add a new service schedule
          </h4>
          <h5>Upload a new Trainsformer export</h5>
          <div :for={entry <- @uploads.trainsformer_export.entries}>
            <progress value={entry.progress} max="100">
              {entry.progress}%
            </progress>
          </div>
          <div class="row">
            <div class="col-lg-3">
              <.button
                disabled={Enum.any?(@uploads.trainsformer_export.entries)}
                type="button"
                class="btn-primary btn-sm w-100"
                phx-click={JS.dispatch("click", to: "##{@uploads.trainsformer_export.ref}")}
                target="_blank"
              >
                <.live_file_input upload={@uploads.trainsformer_export} class="hidden" />
                Upload Trainsformer .zip
              </.button>
            </div>
            <div class="col-lg-3">
              <.link
                id="cancel_add_hastus_export_button"
                class="btn btn-outline-primary btn-sm w-100"
                patch={~p"/disruptions/#{@disruption.id}"}
              >
                Cancel
              </.link>
            </div>
          </div>
        </div>
      </.simple_form>

      <.simple_form
        :if={@show_service_import_form}
        for={@form}
        id="service-import-form"
        phx-submit="save"
        phx-change="validate"
        phx-target={@myself}
      >
        <div class="container-fluid border-2 border-dashed border-primary p-3">
          <div class="text-success mb-3">
            <strong>
              <i>Successfully imported export {@uploaded_file_name}!</i>
            </strong>
          </div>
        </div>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{export: %{id: nil}} = assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:show_upload_form, true)
      |> assign(:show_service_import_form, false)
      |> assign(:form, nil)
      |> allow_upload(:trainsformer_export,
        accept: ~w(.zip),
        progress: &handle_progress/3,
        auto_upload: true
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  defp handle_progress(:trainsformer_export, %UploadEntry{done?: false}, socket) do
    {:noreply, socket}
  end

  defp handle_progress(
         :trainsformer_export,
         %UploadEntry{client_name: client_name} = entry,
         socket
       ) do
    socket = socket |> clear_flash() |> assign(error: nil)

    case consume_uploaded_entry(
           socket,
           entry,
           &ExportUpload.extract_data_from_upload(&1, socket.assigns.user_id)
         ) do
      {:ok, export_data} ->
        form =
          socket.assigns.export
          |> Trainsformer.change_export(%{
            "s3_path" => client_name,
            "disruption_id" => socket.assigns.disruption.id
          })
          |> to_form(action: :validate)

        {:noreply,
         assign(socket,
           form: form,
           show_upload_form: false,
           show_service_import_form: true,
           uploaded_file_name: client_name,
           uploaded_file_data: export_data.zip_binary
         )}
    end
  end
end
