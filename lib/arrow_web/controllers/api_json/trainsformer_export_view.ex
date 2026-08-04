defmodule ArrowWeb.API.TrainsformerExportView do
  use ArrowWeb, :html
  use JaSerializer.PhoenixView

  attributes([:download_url])

  def download_url(export, _conn) do
    {:ok, download_url} = Arrow.Trainsformer.export_download_url(export)
    download_url
  end
end
