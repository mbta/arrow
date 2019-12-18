defmodule ArrowWeb.AuthManager.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :arrow,
    error_handler: ArrowWeb.AuthManager.ErrorHandler,
    module: ArrowWeb.AuthManager

  plug(Guardian.Plug.VerifySession, claims: %{"typ" => "access"})
  plug(Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"})
  plug(Guardian.Plug.LoadResource, allow_blank: true)
end
