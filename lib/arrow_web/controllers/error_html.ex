defmodule ArrowWeb.ErrorView do
  use ArrowWeb, :html

  alias JaSerializer.ErrorSerializer

  # If you want to customize your error pages,
  # uncomment the embed_templates/1 call below
  # and add pages to the error directory:
  #
  #   * lib/<%= @lib_web_name %>/controllers/error/404.html.heex
  #   * lib/<%= @lib_web_name %>/controllers/error/500.html.heex
  #
  # embed_templates "error/*"

  def render("404.json" <> _, _assigns) do
    ErrorSerializer.format(%{
      code: :not_found,
      source: %{parameter: "id"},
      status: "404",
      title: "Resource Not Found"
    })
  end

  # The default is to render a plain text page based on
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def render(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
