defmodule ArrowWeb.DisruptionV2Live.FormComponent do
  use ArrowWeb, :live_component

  alias Arrow.Disruptions

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage disruption_v2 records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="disruption_v2-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Disruption v2</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{disruption_v2: disruption_v2} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Disruptions.change_disruption_v2(disruption_v2))
     end)}
  end

  @impl true
  def handle_event("validate", %{"disruption_v2" => disruption_v2_params}, socket) do
    changeset = Disruptions.change_disruption_v2(socket.assigns.disruption_v2, disruption_v2_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"disruption_v2" => disruption_v2_params}, socket) do
    save_disruption_v2(socket, socket.assigns.action, disruption_v2_params)
  end

  defp save_disruption_v2(socket, :edit, disruption_v2_params) do
    case Disruptions.update_disruption_v2(socket.assigns.disruption_v2, disruption_v2_params) do
      {:ok, disruption_v2} ->
        notify_parent({:saved, disruption_v2})

        {:noreply,
         socket
         |> put_flash(:info, "Disruption v2 updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_disruption_v2(socket, :new, disruption_v2_params) do
    case Disruptions.create_disruption_v2(disruption_v2_params) do
      {:ok, disruption_v2} ->
        notify_parent({:saved, disruption_v2})

        {:noreply,
         socket
         |> put_flash(:info, "Disruption v2 created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
