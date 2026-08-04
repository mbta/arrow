defmodule ArrowWeb.API.HastusExportView do
  use ArrowWeb, :html
  use JaSerializer.PhoenixView

  attributes([:download_url])

  def download_url(export, _conn) do
    {:ok, download_url} = Arrow.Hastus.export_download_url(export)
    download_url
  end
end
