defmodule ArrowWeb.API.DisruptionView do
  use ArrowWeb, :html
  use JaSerializer.PhoenixView

  alias ArrowWeb.API.DisruptionRevisionView

  attributes([:last_published_at])

  has_many :revisions,
    serializer: DisruptionRevisionView,
    include: true

  has_one :published_revision,
    serializer: DisruptionRevisionView,
    include: false

  def published_revision(disruption, _conn) do
    if disruption.published_revision_id do
      %{
        id: disruption.published_revision_id,
        type: "disruption_revision"
      }
    end
  end
end
