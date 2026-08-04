defmodule ArrowWeb.API.DisruptionV2View do
  use ArrowWeb, :html
  use JaSerializer.PhoenixView

  attributes([:title, :mode, :status, :description])

  has_many :limits,
    serializer: ArrowWeb.API.LimitView,
    include: true

  has_many :replacement_services,
    serializer: ArrowWeb.API.ReplacementServiceView,
    include: true

  has_many :hastus_exports,
    serializer: ArrowWeb.API.HastusExportView,
    include: true

  has_many :trainsformer_exports,
    serializer: ArrowWeb.API.TrainsformerExportView,
    include: true

  has_many :shuttles,
    serializer: ArrowWeb.API.ShuttleView,
    include: true
end
