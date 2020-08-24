defmodule Arrow.DisruptionRevisionTest do
  @moduledoc false
  use Arrow.DataCase
  alias Arrow.DisruptionRevision

  describe "publish_all!/0" do
    test "publishes a brand new disruption, and then publishes an update to it" do
      dr = insert(:disruption_revision)

      :ok = DisruptionRevision.publish_all!()

      new_dr = DisruptionRevision |> Arrow.Repo.get(dr.id) |> Arrow.Repo.preload([:disruption])

      assert new_dr.disruption.published_revision_id == dr.id

      {:ok, newer_dr} = Arrow.Disruption.update(new_dr.id, %{end_date: ~D[2020-01-31]})

      :ok = DisruptionRevision.publish_all!()

      newest_dr =
        DisruptionRevision |> Arrow.Repo.get(newer_dr.id) |> Arrow.Repo.preload([:disruption])

      assert newest_dr.disruption.published_revision_id == newer_dr.id
    end
  end
end
