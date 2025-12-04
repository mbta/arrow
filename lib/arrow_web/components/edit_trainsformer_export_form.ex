defmodule ArrowWeb.EditTrainsformerExportForm do
  @moduledoc false
  use ArrowWeb, :live_component

  alias Arrow.Disruptions.DisruptionV2
  alias Arrow.Trainsformer.Export

  attr :disruption, DisruptionV2, required: true
  attr :export, Export, required: true

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
    </div>
    """
  end

  @impl true
  def update(%{export: %{id: nil}} = assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:show_upload_form, true)
      |> assign(:form, nil)
      |> allow_upload(:trainsformer_export, accept: ~w(.zip), auto_upload: true)

    {:ok, socket}
  end
end
