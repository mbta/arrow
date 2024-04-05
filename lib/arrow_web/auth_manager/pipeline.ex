defmodule ArrowWeb.AuthManager.Pipeline do
  @moduledoc false

  use Guardian.Plug.Pipeline,
    otp_app: :arrow,
    error_handler: ArrowWeb.AuthManager.ErrorHandler,
    module: ArrowWeb.AuthManager

  plug(Guardian.Plug.VerifySession, claims: %{"typ" => "access"})
  plug(Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"})
  plug(Guardian.Plug.LoadResource, allow_blank: true)
  plug :refresh_idle_token

  @doc """
  Refreshes the token with each request.

  This allows us to use the `iat` time in the token as an idle timeout.
  """
  def refresh_idle_token(conn, _opts) do
    old_token = Guardian.Plug.current_token(conn)

    case ArrowWeb.AuthManager.refresh(old_token) do
      {:ok, _old, {new_token, _new_claims}} ->
        Guardian.Plug.put_session_token(conn, new_token)

      _ ->
        conn
    end
  end
end
