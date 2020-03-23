defmodule ArrowWeb.API.AdjustmentView do
  use ArrowWeb, :view
  use JaSerializer.PhoenixView

  attributes([:route_id, :source, :source_label])
end
