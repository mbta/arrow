defmodule ArrowWeb.API.ExceptionView do
  use ArrowWeb, :view
  use JaSerializer.PhoenixView

  attributes([
    :id,
    :excluded_date
  ])
end
