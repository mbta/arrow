defmodule ArrowWeb.API.DisruptionDiffView do
  use ArrowWeb, :view
  use JaSerializer.PhoenixView

  attributes([:created?, :diffs])

  has_one :latest_revision,
    serializer: ArrowWeb.API.DisruptionRevisionView,
    include: true

  def id(disruption, _conn) do
    disruption.id
  end
end
