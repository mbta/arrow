defmodule ArrowWeb.API.GtfsImportController do
  use ArrowWeb, :controller
  import Ecto.Query

  # TODO: Authorization

  def import(conn, %{"archive" => %Plug.Upload{} = upload}) do
    version_query =
      from info in Arrow.Gtfs.FeedInfo, where: info.id == "mbta-ma-us", select: info.version

    version = Arrow.Repo.one(version_query)

    case Arrow.Gtfs.import(upload.path, version) do
      :ok ->
        new_version = Arrow.Repo.one!(version_query)

        json(conn, %{old_version: version, new_version: new_version})

      :unchanged ->
        conn
        |> put_status(412)
        |> text("Feed version \"#{version}\" already imported")

      :error ->
        conn
        |> put_status(500)
        |> text("Import failed")
    end
  end
end
