defmodule ArrowWeb.DisruptionController do
  use ArrowWeb, :controller

  alias __MODULE__.{Filters, Index}
  alias Arrow.{Adjustment, Disruption, DisruptionRevision}
  alias ArrowWeb.ErrorHelpers
  alias Ecto.Changeset

  def index(conn, params) do
    filters = Filters.from_params(params)
    render(conn, "index.html", disruptions: Index.all(filters), filters: filters)
  end

  def show(conn, %{"id" => id}) do
    %{id: id, revisions: [revision]} = Disruption.get!(id)
    render(conn, "show.html", id: id, revision: revision)
  end

  def new(conn, _params) do
    changeset = DisruptionRevision.new() |> Changeset.change()
    render(conn, "new.html", adjustments: Adjustment.all(), changeset: changeset)
  end

  def edit(conn, %{"id" => id}) do
    %{revisions: [revision]} = Disruption.get!(id)

    render(conn, "edit.html",
      id: id,
      adjustments: Adjustment.all(),
      changeset: Changeset.change(revision)
    )
  end

  def create(conn, %{"revision" => attrs}) do
    case Disruption.create(attrs) do
      {:ok, %{disruption_id: id}} ->
        conn
        |> put_flash(:info, "Disruption created successfully.")
        |> redirect(to: Routes.disruption_path(conn, :show, id))

      {:error, changeset} ->
        conn
        |> put_flash(:errors, {"Disruption could not be created:", errors(changeset)})
        |> render("new.html", adjustments: Adjustment.all(), changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "revision" => attrs}) do
    case Disruption.update(id, put_new_assocs(attrs)) do
      {:ok, _revision} ->
        conn
        |> put_flash(:info, "Disruption updated successfully.")
        |> redirect(to: Routes.disruption_path(conn, :show, id))

      {:error, changeset} ->
        conn
        |> put_flash(:errors, {"Disruption could not be updated:", errors(changeset)})
        |> render("edit.html", adjustments: Adjustment.all(), changeset: changeset, id: id)
    end
  end

  def delete(conn, %{"id" => id}) do
    _revision = Disruption.delete!(id)
    redirect(conn, to: Routes.disruption_path(conn, :show, id))
  end

  defp errors(changeset) do
    changeset
    |> Changeset.traverse_errors(&ErrorHelpers.translate_error/1)
    |> ErrorHelpers.flatten_errors()
  end

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
