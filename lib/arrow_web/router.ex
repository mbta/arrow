defmodule ArrowWeb.Router do
  use ArrowWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :json_api do
    plug :accepts, ["json-api"]
    plug :fetch_session
    plug JaSerializer.ContentTypeNegotiation
  end

  pipeline :api do
    plug :fetch_session
  end

  pipeline :redirect_prod_http do
    if Application.get_env(:arrow, :redirect_http?) do
      plug(Plug.SSL, rewrite_on: [:x_forwarded_proto])
    end
  end

  pipeline :auth do
    plug(ArrowWeb.AuthManager.Pipeline)
  end

  pipeline :try_api_token_auth do
    plug(ArrowWeb.TryApiTokenAuth)
  end

  pipeline :ensure_auth do
    plug(Guardian.Plug.EnsureAuthenticated)
  end

  pipeline :ensure_arrow_group do
    plug(ArrowWeb.EnsureArrowGroup)
  end

  scope "/", ArrowWeb do
    pipe_through([:redirect_prod_http, :browser, :auth, :ensure_auth])

    get("/unauthorized", UnauthorizedController, :index)
  end

  scope "/", ArrowWeb do
    pipe_through [:redirect_prod_http, :browser, :auth, :ensure_auth, :ensure_arrow_group]

    get "/", DisruptionController, :index
    resources("/disruptions", DisruptionController, only: [:show, :new, :edit])
    get "/mytoken", MyTokenController, :show
  end

  scope "/", ArrowWeb do
    get "/_health", HealthController, :index
  end

  scope "/auth", ArrowWeb do
    pipe_through([:browser])

    get("/:provider", AuthController, :request)
    get("/:provider/callback", AuthController, :callback)
  end

  scope "/api", ArrowWeb.API do
    pipe_through([
      :redirect_prod_http,
      :json_api,
      :auth,
      :try_api_token_auth,
      :ensure_auth,
      :ensure_arrow_group
    ])

    resources("/disruptions", DisruptionController,
      only: [:index, :show, :create, :update, :delete]
    )

    resources("/adjustments", AdjustmentController, only: [:index])
  end

  scope "/api", ArrowWeb.API do
    pipe_through([
      :redirect_prod_http,
      :api,
      :auth,
      :try_api_token_auth,
      :ensure_auth,
      :ensure_arrow_group
    ])

    post "/publish_notice", NoticeController, :publish
    post "/ready_notice", NoticeController, :ready
    get "/db_dump", DBDumpController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", ArrowWeb do
  #   pipe_through :api
  # end
end
