defmodule ArrowWeb.Router do
  alias ArrowWeb.API.GtfsImportController
  use ArrowWeb, :router
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {ArrowWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :json_api do
    plug(:accepts, ["json-api"])
    plug(JaSerializer.ContentTypeNegotiation)
  end

  pipeline :api do
    plug(:fetch_session)
  end

  pipeline :redirect_prod_http do
    if Application.compile_env(:arrow, :redirect_http?) do
      plug(Plug.SSL, rewrite_on: [:x_forwarded_proto])
    end
  end

  pipeline :authenticate do
    plug(ArrowWeb.AuthManager.Pipeline)
    plug(Guardian.Plug.EnsureAuthenticated)
    plug(ArrowWeb.Plug.AssignUser)
  end

  pipeline :authenticate_api do
    plug(ArrowWeb.AuthManager.Pipeline)
    plug(ArrowWeb.TryApiTokenAuth)
    plug(Guardian.Plug.EnsureAuthenticated)
    plug(ArrowWeb.Plug.AssignUser)
  end

  scope "/", ArrowWeb do
    pipe_through([:redirect_prod_http, :browser, :authenticate])

    get("/logout", AuthController, :logout)
    get("/unauthorized", UnauthorizedController, :index)
    get("/feed", FeedController, :index)
    get("/mytoken", MyTokenController, :show)
    get("/", DisruptionController, :index)
    resources("/disruptions", DisruptionController, except: [:index])
    put("/disruptions/:id/row_status", DisruptionController, :update_row_status)
    post("/disruptions/:id/notes", NoteController, :create)
    live("/stops/new", StopViewLive, :new)
    live("/stops/:id/edit", StopViewLive, :edit)
    get("/stops", StopController, :index)
    post("/stops/:id", StopController, :update)
    post("/stops", StopController, :create)
    resources("/shapes", ShapeController, only: [:delete, :index, :show])
    get("/shapes_upload", ShapeController, :new)
    post("/shapes_upload", ShapeController, :create)
    get("/shapes/:id/download", ShapeController, :download)
  end

  scope "/", ArrowWeb do
    get("/_health", HealthController, :index)
  end

  scope "/auth", ArrowWeb do
    pipe_through([:redirect_prod_http, :browser])

    get("/:provider", AuthController, :request)
    get("/:provider/callback", AuthController, :callback)
  end

  scope "/api", as: :api, alias: ArrowWeb.API do
    pipe_through([:redirect_prod_http, :json_api, :authenticate_api])

    resources("/disruptions", DisruptionController, only: [:index])
    resources("/adjustments", AdjustmentController, only: [:index])
    resources("/shuttle-stops", StopsController, only: [:index])
  end

  scope "/api", ArrowWeb.API do
    pipe_through([:redirect_prod_http, :api, :authenticate_api])

    post("/publish_notice", NoticeController, :publish)
    get("/db_dump", DBDumpController, :show)

    scope "/gtfs", alias: false do
      post("/import", GtfsImportController, :enqueue_import)
      get("/import/:id/status", GtfsImportController, :import_status)

      post("/validate", GtfsImportController, :enqueue_validation)
      get("/validate/:id/status", GtfsImportController, :validation_status)

      get("check_jobs", GtfsImportController, :check_jobs)
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", ArrowWeb do
  #   pipe_through :api
  # end

  if Mix.env() == :dev do
    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", ecto_repos: [Arrow.Repo]
    end
  end
end
