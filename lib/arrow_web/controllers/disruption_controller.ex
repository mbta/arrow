defmodule ArrowWeb.DisruptionController do
  use ArrowWeb, :controller

  alias __MODULE__.{Filters, Index}
  alias Arrow.{Adjustment, Disruption, DisruptionRevision, Slack}
  alias ArrowWeb.ErrorHelpers
  alias ArrowWeb.Plug.Authorize
  alias Ecto.Changeset
  alias Plug.Conn

  plug(Authorize, :create_disruption when action in [:new, :create])
  plug(Authorize, :update_disruption when action in [:edit, :update])
  plug(Authorize, :delete_disruption when action in [:delete])

  @spec index(Conn.t(), Conn.params()) :: Conn.t()
  def index(%{assigns: %{current_user: user}} = conn, params) do
    filters = Filters.from_params(params)

    render(conn, "index.html", disruptions: Index.all(filters), filters: filters, user: user)
  end

  @spec show(Conn.t(), Conn.params()) :: Conn.t()
  def show(%{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    %{id: id, revisions: [revision]} = Disruption.get!(id)
    render(conn, "show.html", id: id, revision: revision, user: user)
  end

  @spec new(Conn.t(), Conn.params()) :: Conn.t()
  def new(conn, _params) do
    changeset = DisruptionRevision.new() |> Changeset.change()
    render(conn, "new.html", adjustments: Adjustment.all(), changeset: changeset)
  end

  @spec edit(Conn.t(), Conn.params()) :: Conn.t()
  def edit(conn, %{"id" => id}) do
    %{revisions: [revision]} = Disruption.get!(id)

    render(conn, "edit.html",
      id: id,
      adjustments: Adjustment.all(),
      changeset: Changeset.change(revision)
    )
  end

  @spec create(Conn.t(), Conn.params()) :: Conn.t()
  def create(conn, %{"revision" => attrs}) do
    case Disruption.create(attrs) do
      {:ok, %{disruption_id: id} = revision} ->
        Slack.Notifier.created(revision)

        conn
        |> put_flash(:info, "Disruption created successfully.")
        |> redirect(to: Routes.disruption_path(conn, :show, id))

      {:error, changeset} ->
        conn
        |> put_flash(:errors, {"Disruption could not be created:", errors(changeset)})
        |> render("new.html", adjustments: Adjustment.all(), changeset: changeset)
    end
  end

  @spec update(Conn.t(), Conn.params()) :: Conn.t()
  def update(conn, %{"id" => id, "revision" => attrs}) do
    before_update = Disruption.get!(id).revisions |> Enum.at(0)

    case Disruption.update(id, put_new_assocs(attrs)) do
      {:ok, revision} ->
        Slack.Notifier.edited(before_update, revision)

        conn
        |> put_flash(:info, "Disruption updated successfully.")
        |> redirect(to: Routes.disruption_path(conn, :show, id))

      {:error, changeset} ->
        conn
        |> put_flash(:errors, {"Disruption could not be updated:", errors(changeset)})
        |> render("edit.html", adjustments: Adjustment.all(), changeset: changeset, id: id)
    end
  end

  @spec delete(Conn.t(), Conn.params()) :: Conn.t()
  def delete(conn, %{"id" => id}) do
    revision = Disruption.delete!(id)
    Slack.Notifier.cancelled(revision)
    redirect(conn, to: Routes.disruption_path(conn, :show, id))
  end

  @spec errors(Changeset.t()) :: [String.t()]
  defp errors(changeset) do
    changeset
    |> Changeset.traverse_errors(&ErrorHelpers.translate_error/1)
    |> ErrorHelpers.flatten_errors()
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
