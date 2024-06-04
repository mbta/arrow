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

  def controller do
    quote do
      use Phoenix.Controller, namespace: ArrowWeb

      import Plug.Conn
      import ArrowWeb.Gettext
      alias ArrowWeb.Router.Helpers, as: Routes
    end
  end

  def html do
    quote do
      use Phoenix.Component
      # Use all HTML functionality (forms, tags, etc)
      # Still needed for old style Phoenix HTML like <link>, <content_tag>
      use Phoenix.HTML

      import ArrowWeb.ErrorHelpers
      import ArrowWeb.Gettext
      alias ArrowWeb.Router.Helpers, as: Routes

      # Import the `react_component` helper
      import ReactPhoenix.ClientSide
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import ArrowWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
