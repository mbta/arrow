defmodule ArrowWeb.API.DisruptionV2View do
  use ArrowWeb, :html
  use JaSerializer.PhoenixView

  attributes([:title, :mode, :status, :description, :hastus_exports, :trainsformer_exports])

  has_many :limits,
    serializer: ArrowWeb.API.LimitView,
    include: true

  has_many :replacement_services,
    serializer: ArrowWeb.API.ReplacementServiceView,
    include: true

  has_many :shuttles,
    serializer: ArrowWeb.API.ShuttleView,
    include: true
end
