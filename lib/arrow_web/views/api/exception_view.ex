defmodule ArrowWeb.API.ExceptionView do
  use ArrowWeb, :view
  use JaSerializer.PhoenixView

  attributes([
    :excluded_date
  ])
end
