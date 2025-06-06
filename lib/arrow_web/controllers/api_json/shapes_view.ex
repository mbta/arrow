defmodule ArrowWeb.API.ShapesView do
  use ArrowWeb, :html
  use JaSerializer.PhoenixView

  attributes([:name, :bucket, :path, :prefix, :download_url, :inserted_at, :updated_at])

  def download_url(shape, _conn) do
    enabled? = Application.get_env(:arrow, :shape_storage_enabled?)
    basic_url = "https://#{shape.bucket}.s3.amazonaws.com/#{shape.path}"

    if enabled? do
      case ExAws.S3.presigned_url(ExAws.Config.new(:s3), :get, shape.bucket, shape.path, []) do
        {:ok, url} -> url
        {:error, _} -> basic_url
      end
    else
      basic_url
    end
  end
end
