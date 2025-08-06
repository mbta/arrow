defmodule ArrowWeb.NoteController do
  use ArrowWeb, :controller

  alias Arrow.Disruption
  alias ArrowWeb.ErrorHelpers
  alias ArrowWeb.Plug.Authorize

  plug(Authorize, :create_note when action in [:create])

  def create(%{assigns: %{current_user: user}} = conn, %{"id" => disruption_id, "note" => note_attrs}) do
    case Disruption.add_note(String.to_integer(disruption_id), user.id, note_attrs) do
      {:ok, _} ->
        redirect(conn, to: Routes.disruption_path(conn, :show, disruption_id))

      {:error, changeset} ->
        conn
        |> put_flash(
          :errors,
          {"Note could not be created", ErrorHelpers.changeset_error_messages(changeset)}
        )
        |> redirect(to: Routes.disruption_path(conn, :show, disruption_id))
    end
  end
end
