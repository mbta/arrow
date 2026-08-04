defmodule ArrowWeb.API.DisruptionV2View do
  use ArrowWeb, :html
  use JaSerializer.PhoenixView

  attributes([:title, :mode, :status, :description, :hastus_exports, :trainsformer_exports])

  def hastus_exports(disruption, _conn) do
    disruption.hastus_exports
    |> Enum.map(fn export ->
      {:ok, download_url} = Arrow.Hastus.export_download_url(export)
      download_url
    end)
  end

  def trainsformer_exports(disruption, _conn) do
    disruption.trainsformer_exports
    |> Enum.map(fn export ->
      {:ok, download_url} = Arrow.Trainsformer.export_download_url(export)
      download_url
    end)
  end

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
