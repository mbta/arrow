defmodule ArrowWeb.DisruptionController do
  use ArrowWeb, :controller

  alias __MODULE__.{Filters, Index}
  alias Arrow.{Adjustment, Disruption, DisruptionRevision}
  alias ArrowWeb.ErrorHelpers
  alias ArrowWeb.Plug.Authorize
  alias Ecto.Changeset
  alias Plug.Conn

  plug(Authorize, :view_disruption when action in [:index, :show])
  plug(Authorize, :create_disruption when action in [:new, :create])
  plug(Authorize, :update_disruption when action in [:edit, :update, :update_row_status])
  plug(Authorize, :delete_disruption when action in [:delete])

  @spec update_row_status(Conn.t(), Conn.params()) :: Conn.t()
  def update_row_status(%{assigns: %{current_user: user}} = conn, %{
        "id" => id,
        "revision" => attrs
      }) do
    {:ok, _} = Disruption.update(id, user.id, attrs)

    conn
    |> put_flash(:info, "Disruption updated successfully.")
    |> redirect(to: Routes.disruption_path(conn, :show, id))
  end

  @spec index(Conn.t(), Conn.params()) :: Conn.t()
  def index(%{assigns: %{current_user: user}} = conn, params) do
    filters = Filters.from_params(params)

    render(conn, "index.html", disruptions: Index.all(filters), filters: filters, user: user)
  end

  @spec show(Conn.t(), Conn.params()) :: Conn.t()
  def show(%{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    %{id: id, revisions: [revision], notes: notes} = Disruption.get!(id)
    render(conn, "show.html", id: id, revision: revision, user: user, notes: notes)
  end

  @spec new(Conn.t(), Conn.params()) :: Conn.t()
  def new(conn, _params) do
    changeset = DisruptionRevision.new() |> Changeset.change()
    render(conn, "new.html", adjustments: Adjustment.all(), changeset: changeset, note_body: "")
  end

  @spec edit(Conn.t(), Conn.params()) :: Conn.t()
  def edit(conn, %{"id" => id}) do
    %{revisions: [revision]} = Disruption.get!(id)

    render(conn, "edit.html",
      id: id,
      adjustments: Adjustment.all(),
      changeset: Changeset.change(revision),
      note_body: ""
    )
  end

  @spec create(Conn.t(), Conn.params()) :: Conn.t()
  def create(%{assigns: %{current_user: user}} = conn, %{"revision" => attrs}) do
    case Disruption.create(user.id, attrs) do
      {:ok, %{disruption: %{id: id}}} ->
        conn
        |> put_flash(:info, "Disruption created successfully.")
        |> redirect(to: Routes.disruption_path(conn, :show, id))

      {:error, :revision, changeset, _} ->
        conn
        |> put_flash(
          :errors,
          {"Disruption could not be created:", ErrorHelpers.changeset_error_messages(changeset)}
        )
        |> render("new.html", adjustments: Adjustment.all(), changeset: changeset)
    end
  end

  @spec update(Conn.t(), Conn.params()) :: Conn.t()
  def update(%{assigns: %{current_user: user}} = conn, %{"id" => id, "revision" => attrs}) do
    case Disruption.update(id, user.id, put_new_assocs(attrs)) do
      {:ok, _multi} ->
        conn
        |> put_flash(:info, "Disruption updated successfully.")
        |> redirect(to: Routes.disruption_path(conn, :show, id))

      {:error, :revision, changeset, _} ->
        conn
        |> put_flash(
          :errors,
          {"Disruption could not be updated:", ErrorHelpers.changeset_error_messages(changeset)}
        )
        |> render("edit.html", adjustments: Adjustment.all(), changeset: changeset, id: id)
    end
  end

  @spec delete(Conn.t(), Conn.params()) :: Conn.t()
  def delete(conn, %{"id" => id}) do
    _revision = Disruption.delete!(id)
    redirect(conn, to: Routes.disruption_path(conn, :show, id))
  end

  @spec put_new_assocs(%{optional(binary) => any}) :: %{binary => any}
  defp put_new_assocs(attrs) do
    # Ensure a form submission with no instances of an association is interpreted as "delete all
    # existing records" rather than "leave existing records alone"
    attrs
    |> Map.put_new("adjustments", [])
    |> Map.put_new("days_of_week", [])
    |> Map.put_new("exceptions", [])
    |> Map.put_new("trip_short_names", [])
  end
end
