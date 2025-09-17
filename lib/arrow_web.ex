defmodule ArrowWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use ArrowWeb, :controller

      https://hexdocs.pm/phoenix_view/Phoenix.View.html#module-replaced-by-phoenix-component
      use ArrowWeb, :html

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """
  def static_paths, do: ~w(assets fonts images icons favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router
      import Phoenix.LiveView.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      use Gettext, backend: ArrowWeb.Gettext
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, formats: [html: "View", json: "View", "json-api": "View"]

      import Plug.Conn
      use Gettext, backend: ArrowWeb.Gettext
      alias ArrowWeb.Router.Helpers, as: Routes

      unquote(verified_routes())
    end
  end

  def html do
    quote do
      use Phoenix.Component
      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())

      # https://hexdocs.pm/phoenix_html/changelog.html#v4-0-0-2023-12-19
      # Use all HTML functionality (forms, tags, etc)
      # Still needed for old style Phoenix HTML like <link>, <content_tag>
      import Phoenix.HTML
      import Phoenix.HTML.Form
      use PhoenixHTMLHelpers

      import ArrowWeb.ErrorHelpers
      use Gettext, backend: ArrowWeb.Gettext
      alias ArrowWeb.Router.Helpers, as: Routes

      # Import the `react_component` helper
      import ReactPhoenix.ClientSide
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components and translation
      import ArrowWeb.CoreComponents
      import ArrowWeb.Helpers
      use Gettext, backend: ArrowWeb.Gettext

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {ArrowWeb.LayoutView, :live}

      unquote(html_helpers())

      # Import the `live_react_component` helper
      import PhoenixLiveReact
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())

      # Import the `live_react_component` helper
      import PhoenixLiveReact
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: ArrowWeb.Endpoint,
        router: ArrowWeb.Router,
        statics: ArrowWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/live_view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
