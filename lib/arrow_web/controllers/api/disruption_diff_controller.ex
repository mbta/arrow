defmodule ArrowWeb.API.DisruptionDiffController do
  use ArrowWeb, :controller
  alias Arrow.Disruption

  def index(conn, _params) do
    {updated, new} = Disruption.draft_vs_published()

    updated =
      Enum.map(updated, fn disruption ->
        %Arrow.DisruptionDiff{
          id: disruption.id,
          latest_revision: Enum.at(disruption.revisions, -1),
          created?: false,
          diffs: Arrow.Disruption.diff_revisions(disruption)
        }
      end)

    new =
      Enum.map(new, fn disruption ->
        %Arrow.DisruptionDiff{
          id: disruption.id,
          latest_revision: Enum.at(disruption.revisions, -1),
          created?: true,
          diffs: []
        }
      end)

    render(conn, "index.json-api", data: new ++ updated)
  end
end
