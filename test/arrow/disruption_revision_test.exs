defmodule Arrow.DisruptionRevisionTest do
  @moduledoc false
  use Arrow.DataCase
  alias Arrow.DisruptionRevision
  import Ecto.Query

  describe "only_ready/1" do
    test "returns nothing when ready revision of a disruption is deleted" do
      dr1 = insert(:disruption_revision) |> Arrow.Repo.preload([:disruption])

      :ok = DisruptionRevision.ready_all!()

      {:ok, _dr2} = Arrow.Disruption.delete(dr1.id)

      :ok = DisruptionRevision.ready_all!()

      ready_dr =
        DisruptionRevision
        |> DisruptionRevision.only_ready()
        |> Repo.get_by(disruption_id: dr1.disruption.id)

      assert is_nil(ready_dr)
    end
  end

  describe "latest_revision/1" do
    test "returns nothing when latest revision of a disruption is deleted" do
      dr1 = insert(:disruption_revision) |> Arrow.Repo.preload([:disruption])

      :ok = DisruptionRevision.ready_all!()

      {:ok, _dr2} = Arrow.Disruption.delete(dr1.id)

      ready_dr =
        DisruptionRevision
        |> DisruptionRevision.latest_revision()
        |> Repo.get_by(disruption_id: dr1.disruption.id)

      assert is_nil(ready_dr)
    end
  end

  describe "ready_all!/0" do
    test "readies a brand new disruption, and then readies an update to it" do
      dr = insert(:disruption_revision)

      :ok = DisruptionRevision.ready_all!()

      new_dr = DisruptionRevision |> Arrow.Repo.get(dr.id) |> Arrow.Repo.preload([:disruption])

      assert new_dr.disruption.ready_revision_id == dr.id

      {:ok, newer_d} = Arrow.Disruption.update(new_dr.id, %{end_date: ~D[2020-01-31]})

      newer_d = Arrow.Repo.preload(newer_d, [:revisions])

      :ok = DisruptionRevision.ready_all!()

      newest_d = Arrow.Repo.get(Arrow.Disruption, newer_d.id)

      assert newest_d.ready_revision_id == newer_d.revisions |> Enum.map(& &1.id) |> Enum.max()
    end
  end

  describe "publish!/1" do
    test "updates published revision ID" do
      d = insert(:disruption)
      dr = insert(:disruption_revision, %{disruption: d})

      refute d.last_published_at

      :ok = DisruptionRevision.ready_all!()

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

      changing
      |> change(ready_revision: changing_rev2, published_revision: changing_rev1)
      |> Repo.update!()

      unchanging
      |> change(ready_revision: unchanging_rev, published_revision: unchanging_rev)
      |> Repo.update!()

      :ok = DisruptionRevision.publish!([changing_rev2.id, unchanging_rev.id])

      assert Repo.reload!(changing).last_published_at != timestamp
      assert Repo.reload!(unchanging).last_published_at == timestamp
    end

    test "raises exception when trying to publish revision more recent than ready revision" do
      d1 = insert(:disruption)
      dr1 = insert(:disruption_revision, %{disruption: d1})

      d2 = insert(:disruption)
      _dr2_1 = insert(:disruption_revision, %{disruption: d2})

      :ok = DisruptionRevision.ready_all!()

      dr2_2 = insert(:disruption_revision, %{disruption: d2})

      assert_raise Arrow.Disruption.PublishedAfterReadyError, fn ->
        DisruptionRevision.publish!([dr1.id, dr2_2.id])
      end

      new_d1 = Arrow.Repo.get(Arrow.Disruption, d1.id)

      assert is_nil(new_d1.published_revision_id)

      new_d2 = Arrow.Repo.get(Arrow.Disruption, d2.id)

      assert is_nil(new_d2.published_revision_id)
    end

    test "raises exception when trying to publish revision with no ready revision" do
      d1 = insert(:disruption)
      dr1 = insert(:disruption_revision, %{disruption: d1})

      :ok = DisruptionRevision.ready_all!()

      d2 = insert(:disruption)
      dr2 = insert(:disruption_revision, %{disruption: d2})

      assert_raise Arrow.Disruption.PublishedAfterReadyError, fn ->
        DisruptionRevision.publish!([dr1.id, dr2.id])
      end

      new_d1 = Arrow.Repo.get(Arrow.Disruption, d1.id)

      assert is_nil(new_d1.published_revision_id)

      new_d2 = Arrow.Repo.get(Arrow.Disruption, d2.id)

      assert is_nil(new_d2.published_revision_id)
    end
  end

  describe "ready!/1" do
    test "updates ready revision ID" do
      d = insert(:disruption)
      dr = insert(:disruption_revision, %{disruption: d})

      assert :ok = DisruptionRevision.ready!([dr.id])

      new_d = Arrow.Repo.get(Arrow.Disruption, d.id)

      assert new_d.ready_revision_id == dr.id
    end

    test "raises exception when trying to ready a revision more recent that is not latest revision" do
      d1 = insert(:disruption)
      dr1 = insert(:disruption_revision, %{disruption: d1})
      _dr2 = insert(:disruption_revision, %{disruption: d1})

      assert_raise Arrow.Disruption.ReadyNotLatestError, fn ->
        DisruptionRevision.ready!([dr1.id])
      end

      new_d1 = Arrow.Repo.get(Arrow.Disruption, d1.id)

      assert is_nil(new_d1.ready_revision_id)
    end
  end

  describe "only_ready/1 and latest_revision/1" do
    test "Returns the respective views of the disruption" do
      d = insert(:disruption)
      dr1 = insert(:disruption_revision, %{disruption: d})
      d |> Ecto.Changeset.change(%{ready_revision_id: dr1.id}) |> Repo.update!()
      _dr2 = insert(:disruption_revision, %{disruption: d})
      dr3 = insert(:disruption_revision, %{disruption: d})

      base = from(d in Arrow.DisruptionRevision)

      ready_id = dr1.id
      draft_id = dr3.id

      assert [
               %{id: ^ready_id}
             ] = base |> Arrow.DisruptionRevision.only_ready() |> Repo.all()

      assert [
               %{id: ^draft_id}
             ] = base |> Arrow.DisruptionRevision.latest_revision() |> Repo.all()
    end
  end
end
