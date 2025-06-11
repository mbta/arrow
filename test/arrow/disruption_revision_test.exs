defmodule Arrow.DisruptionRevisionTest do
  @moduledoc false
  use Arrow.DataCase

  alias Arrow.DisruptionRevision

  describe "adjustment_kinds/1" do
    test "returns just the revision's `adjustment_kind` if not nil" do
      revision = build(:disruption_revision, adjustment_kind: :red_line)
      assert DisruptionRevision.adjustment_kinds(revision) == [:red_line]
    end

    test "returns the distinct kinds of the revision's adjustments" do
      revision =
        build(:disruption_revision,
          adjustments: [
            build(:adjustment, route_id: "Green-D"),
            build(:adjustment, route_id: "CR-Franklin"),
            build(:adjustment, route_id: "CR-Fitchburg")
          ]
        )

      assert DisruptionRevision.adjustment_kinds(revision) == ~w(green_line_d commuter_rail)a
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
