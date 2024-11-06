defmodule ArrowWeb.ShuttleViewLive do
  use ArrowWeb, :live_view
  import Phoenix.HTML.Form
  alias Arrow.Shuttles
  alias Arrow.Shuttles.Shuttle

  embed_templates "shuttle_live/*"

  @doc """
  Renders a shuttle route form
  """
  attr :form, :any, required: true
  attr :action, :string, required: true
  attr :http_action, :string
  attr :gtfs_disruptable_routes, :list, required: true
  attr :shapes, :list, required: true

  def shuttle_form(assigns) do
    ~H"""
    <.simple_form
      :let={f}
      for={@form}
      as={:shuttle}
      action={@http_action}
      phx-submit={@action}
      id="shuttle-form"
    >
      <div class="form-group">
        <a
          target="_blank"
          rel="noreferrer noopener"
          href="https://www.notion.so/native/mbta-downtown-crossing/Conventions-for-shuttle-bus-information-fc5a788409b24eb088dbfe3a43abf67e?pvs=4&deepLinkOpenNewTab=true#2b8886089b25403991f1ed69144d8fd8"
        >
          View Shuttle Definition Conventions
        </a>
      </div>
      <.error :if={@form.action}>
        Oops, something went wrong! Please check the errors below.
      </.error>
      <div class="row">
        <div class="col">
          <.input field={f[:shuttle_name]} type="text" label="Shuttle Name" />
        </div>
        <div class="col">
          <.input
            field={f[:disrupted_route_id]}
            type="select"
            label="Disrupted Route"
            prompt="Choose a route"
            options={Enum.map(@gtfs_disruptable_routes, &{&1.long_name, &1.id})}
          />
        </div>
        <div class="col">
          <.input
            field={f[:status]}
            type="select"
            label="Status"
            prompt="Choose a value"
            options={Ecto.Enum.values(Arrow.Shuttles.Shuttle, :status)}
          />
        </div>
      </div>
      <hr />
      <h2>define route</h2>
      <.inputs_for :let={f_route} field={f[:routes]}>
        <h4>direction <%= input_value(f_route, :direction_id) %></h4>
        <div class="row">
          <div class="hidden">
            <.input field={f_route[:direction_id]} type="text" label="Direction id" />
          </div>
          <div class="col">
            <.input field={f_route[:direction_desc]} type="text" label="Direction desc" />
          </div>
          <div class="col offset-md-1">
            <.input
              field={f_route[:shape_id]}
              type="select"
              label="Shape"
              prompt="Choose a shape"
              options={Enum.map(@shapes, &{&1.name, &1.id})}
            />
          </div>
        </div>
        <div class="row">
          <div class="col">
            <.input field={f_route[:destination]} type="text" label="Destination" />
          </div>
          <div class="col-1 align-self-end italic">
            <div class="form-group">
              via
            </div>
          </div>
          <div class="col">
            <.input field={f_route[:waypoint]} type="text" label="Waypoint" />
          </div>
        </div>
        <div class="row">
          <div class="col">
            <.input field={f_route[:suffix]} type="text" label="Suffix" />
          </div>
        </div>
      </.inputs_for>
      <:actions>
        <.button>Save Shuttle</.button>
      </:actions>
    </.simple_form>
    """
  end

  def mount(%{"id" => id} = _params, session, socket) do
    logout_url = session["logout_url"]
    shuttle = Shuttles.get_shuttle!(id)
    changeset = Shuttles.change_shuttle(shuttle)
    gtfs_disruptable_routes = Shuttles.list_disruptable_routes()
    shapes = Shuttles.list_shapes()
    form = to_form(changeset)

    socket =
      socket
      |> assign(:form, form)
      |> assign(:form_action, "edit")
      |> assign(:http_action, ~p"/shuttles/#{id}")
      |> assign(:shuttle, shuttle)
      |> assign(:title, "edit shuttle")
      |> assign(:gtfs_disruptable_routes, gtfs_disruptable_routes)
      |> assign(:shapes, shapes)
      |> assign(:logout_url, logout_url)

    {:ok, socket}
  end

  def mount(%{} = _params, session, socket) do
    logout_url = session["logout_url"]

    changeset =
      Shuttles.change_shuttle(%Shuttle{
        status: :draft,
        routes: [%Shuttles.Route{direction_id: :"0"}, %Shuttles.Route{direction_id: :"1"}]
      })

    gtfs_disruptable_routes = Shuttles.list_disruptable_routes()
    shapes = Shuttles.list_shapes()
    form = to_form(changeset)

    socket =
      socket
      |> assign(:form, form)
      |> assign(:form_action, "create")
      |> assign(:http_action, ~p"/shuttles")
      |> assign(:title, "create new replacement service shuttle")
      |> assign(:gtfs_disruptable_routes, gtfs_disruptable_routes)
      |> assign(:shapes, shapes)
      |> assign(:logout_url, logout_url)

    {:ok, socket}
  end

  def handle_event("validate", %{"shuttle" => shuttle_params}, socket) do
    form =
      %Shuttle{} |> Shuttles.change_shuttle(shuttle_params) |> to_form(action: :validate)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("edit", %{"shuttle" => shuttle_params}, socket) do
    shuttle = Shuttles.get_shuttle!(socket.assigns.shuttle.id)

    case Arrow.Shuttles.update_shuttle(shuttle, shuttle_params) do
      {:ok, shuttle} ->
        {:noreply,
         socket
         |> put_flash(:info, "Shuttle updated successfully")
         |> redirect(to: ~p"/shuttles/#{shuttle}")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("create", %{"shuttle" => shuttle_params}, socket) do
    case Arrow.Shuttles.create_shuttle(shuttle_params) do
      {:ok, shuttle} ->
        {:noreply,
         socket
         |> put_flash(:info, "Shuttle created successfully")
         |> redirect(to: ~p"/shuttles/#{shuttle}")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
