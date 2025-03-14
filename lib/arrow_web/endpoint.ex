defmodule ArrowWeb.Endpoint do
  use Sentry.PlugCapture
  use Phoenix.Endpoint, otp_app: :arrow

  if Application.compile_env(:arrow, :env) == :test do
    plug Phoenix.Ecto.SQL.Sandbox, sandbox: Ecto.Adapters.SQL.Sandbox
  end

  @session_options [
    store: :cookie,
    key: "_arrow_key",
    signing_salt: "35DDvOCJ",
    same_site: "Lax"
  ]

  socket "/socket", ArrowWeb.UserSocket,
    websocket: true,
    longpoll: false

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :arrow,
    gzip: false,
    only: ArrowWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, {:multipart, length: 100_000_000}, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  # Sentry must be invoked after Plug.Parsers:
  plug(Sentry.PlugContext)

  plug Plug.MethodOverride
  plug Plug.Head
  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session, @session_options

  plug ArrowWeb.Router
end
