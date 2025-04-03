defmodule ArrowWeb.API.AdjustmentView do
  use ArrowWeb, :html
  use JaSerializer.PhoenixView

  attributes([:route_id, :source, :source_label])
end
