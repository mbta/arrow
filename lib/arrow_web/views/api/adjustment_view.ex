defmodule ArrowWeb.API.AdjustmentView do
  use ArrowWeb, :view
  use JaSerializer.PhoenixView

  attributes([:id, :route_id, :source, :source_label])
end
