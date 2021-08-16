defmodule Arrow.DisruptionRevisionTest do
  @moduledoc false
  use Arrow.DataCase
  alias Arrow.DisruptionRevision
  import Ecto.Query

  describe "latest_revision/1" do
    test "selects revisions that are the latest revision of their disruption" do
      d = insert(:disruption)
      insert(:disruption_revision, %{disruption: d})
      %{id: latest_id} = insert(:disruption_revision, %{disruption: d})

      base = from(d in Arrow.DisruptionRevision)

      assert [
               %{id: ^latest_id}
             ] = base |> Arrow.DisruptionRevision.latest_revision() |> Repo.all()
    end

    test "returns nothing when latest revision of a disruption is deleted" do
      dr1 = insert(:disruption_revision) |> Arrow.Repo.preload([:disruption])

      {:ok, _dr2} = Arrow.Disruption.delete(dr1.id)

      latest_dr =
        DisruptionRevision
        |> DisruptionRevision.latest_revision()
        |> Repo.get_by(disruption_id: dr1.disruption.id)

      assert is_nil(latest_dr)
    end
  end

  describe "publish!/1" do
    test "updates published revision ID" do
      d = insert(:disruption, last_published_at: nil)
      dr = insert(:disruption_revision, %{disruption: d})

      assert :ok = DisruptionRevision.publish!([dr.id])

      new_d = Arrow.Repo.get(Arrow.Disruption, d.id)
      assert new_d.published_revision_id == dr.id
      assert_in_delta(DateTime.to_unix(new_d.last_published_at), :os.system_time(:second), 60)
    end

    test "only updates last_published_at for disruptions whose published revision changed" do
      timestamp = ~U[2020-01-01 00:00:00Z]
      [changing, unchanging] = insert_list(2, :disruption, last_published_at: timestamp)
      [changing_rev1, changing_rev2] = insert_list(2, :disruption_revision, disruption: changing)
      unchanging_rev = insert(:disruption_revision, disruption: unchanging)
      changing |> change(published_revision: changing_rev1) |> Repo.update!()
      unchanging |> change(published_revision: unchanging_rev) |> Repo.update!()

      :ok = DisruptionRevision.publish!([changing_rev2.id, unchanging_rev.id])

      assert Repo.reload!(changing).last_published_at != timestamp
      assert Repo.reload!(unchanging).last_published_at == timestamp
    end

    test "publishes deleted revisions" do
      d = insert(:disruption)
      dr1 = insert(:disruption_revision, %{disruption: d, is_active: false})

      assert :ok = DisruptionRevision.publish!([])

      d = Arrow.Repo.get(Arrow.Disruption, d.id)
      assert d.published_revision_id == dr1.id
    end
  end
end
