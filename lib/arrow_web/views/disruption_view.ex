defmodule ArrowWeb.DisruptionView do
  use ArrowWeb, :view

  def adjustments(adjustments) do
    Enum.map(adjustments, fn a ->
      %{
        id: a.id,
        routeId: a.route_id,
        sourceLabel: a.source_label
      }
    end)
  end
end
