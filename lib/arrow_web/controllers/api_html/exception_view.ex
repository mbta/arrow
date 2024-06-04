defmodule ArrowWeb.API.ExceptionView do
  use ArrowWeb, :html
  use JaSerializer.PhoenixView

  attributes([
    :excluded_date
  ])
end
