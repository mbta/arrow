defmodule ArrowWeb.DisruptionController do
  use ArrowWeb, :controller
  alias Arrow.Adjustment
  alias Arrow.Disruption
  alias Arrow.DisruptionRevision
  alias Arrow.Repo
  import Ecto.Query

  def new(conn, _params) do
    adjustments = from(adj in Adjustment) |> Repo.all()
    render(conn, "new.html", adjustments: adjustments)
  end

  def edit(conn, %{"id" => id} = params) do
    IO.inspect(params, label: "params")

    disruption_revision =
      from(dr in DisruptionRevision,
        where: dr.disruption_id == ^id,
        order_by: [desc: dr.inserted_at]
      )
      |> preload([:adjustments, :days_of_week, :exceptions, :trip_short_names])
      |> Repo.one()

    all_adjustments =
      from(adj in Adjustment)
      |> Repo.all()

    IO.inspect(disruption_revision, label: "disruption")

    render(conn, "edit.html",
      disruption_revision: disruption_revision,
      all_adjustments: all_adjustments
    )
  end

  def create(conn, params) do
    IO.inspect(params)
  end
end
