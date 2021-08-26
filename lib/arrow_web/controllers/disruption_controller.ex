defmodule ArrowWeb.DisruptionController do
  use ArrowWeb, :controller

  alias __MODULE__.{Filters, Index}
  alias Arrow.{Adjustment, Disruption, DisruptionRevision, Repo}
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
    render(conn, "new.html", adjustments: adjustments(), changeset: changeset)
  end

  def edit(conn, %{"id" => id}) do
    %{revisions: [revision]} = Disruption.get!(id)

    render(conn, "edit.html",
      id: id,
      adjustments: adjustments(),
      changeset: Changeset.change(revision)
    )
  end

  def create(conn, %{"revision" => attrs}) do
    case Disruption.create(attrs) do
      {:ok, id} ->
        conn
        |> put_flash(:info, "Disruption created successfully.")
        |> redirect(to: Routes.disruption_path(conn, :show, id))

      {:error, changeset} ->
        conn
        |> put_flash(:errors, {"Disruption could not be created:", errors(changeset)})
        |> render("new.html", adjustments: adjustments(), changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "revision" => attrs}) do
    case Disruption.update(id, attrs) do
      {:ok, id} ->
        conn
        |> put_flash(:info, "Disruption updated successfully.")
        |> redirect(to: Routes.disruption_path(conn, :show, id))

      {:error, changeset} ->
        conn
        |> put_flash(:errors, {"Disruption could not be updated:", errors(changeset)})
        |> render("edit.html", adjustments: adjustments(), changeset: changeset, id: id)
    end
  end

  def delete(conn, %{"id" => id}) do
    _revision = Disruption.delete!(id)
    redirect(conn, to: Routes.disruption_path(conn, :show, id))
  end

  defp adjustments, do: Repo.all(Adjustment)

  defp errors(changeset) do
    changeset
    |> Changeset.traverse_errors(&ErrorHelpers.translate_error/1)
    |> ErrorHelpers.flatten_errors()
  end
end
