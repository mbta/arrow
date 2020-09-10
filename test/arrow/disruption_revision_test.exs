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

  describe "diff/2" do
    test "Returns a list of changes between two disruption revisions" do
      d = insert(:disruption)

      dr1 =
        insert(:disruption_revision, %{
          disruption: d,
          start_date: ~D[2020-03-31],
          end_date: ~D[2020-05-05],
          days_of_week: [
            build(:day_of_week, %{day_name: "monday", start_time: nil, end_time: ~T[20:00:00]}),
            build(:day_of_week, %{day_name: "tuesday", start_time: nil, end_time: ~T[20:00:00]}),
            build(:day_of_week, %{
              day_name: "friday",
              start_time: ~T[10:00:00],
              end_time: ~T[20:00:00]
            })
          ],
          exceptions: [
            build(:exception, %{excluded_date: ~D[2020-04-01]}),
            build(:exception, %{excluded_date: ~D[2020-04-02]})
          ],
          trip_short_names: [
            build(:trip_short_name, %{trip_short_name: "111"}),
            build(:trip_short_name, %{trip_short_name: "222"})
          ]
        })

      dr2 =
        insert(:disruption_revision, %{
          disruption: d,
          start_date: ~D[2020-03-31],
          end_date: ~D[2020-05-15],
          days_of_week: [
            build(:day_of_week, %{day_name: "monday", start_time: ~T[05:00:00], end_time: nil}),
            build(:day_of_week, %{
              day_name: "wednesday",
              start_time: ~T[10:00:00],
              end_time: ~T[20:00:00]
            }),
            build(:day_of_week, %{
              day_name: "friday",
              start_time: ~T[10:00:00],
              end_time: ~T[20:00:00]
            })
          ],
          exceptions: [
            build(:exception, %{excluded_date: ~D[2020-04-01]}),
            build(:exception, %{excluded_date: ~D[2020-04-04]})
          ],
          trip_short_names: [
            build(:trip_short_name, %{trip_short_name: "111"}),
            build(:trip_short_name, %{trip_short_name: "333"})
          ]
        })

      assert Arrow.DisruptionRevision.diff(dr1, dr2) == [
               "End date changed from 2020-05-05 to 2020-05-15",
               "The following exception dates were added: 2020-04-04",
               "The following exception dates were deleted: 2020-04-02",
               "The following trip short names were added: 333",
               "The following trip short names were deleted: 222",
               "Added wednesday",
               "Removed tuesday",
               "Changed monday end time from 20:00:00 to EoS"
             ]
    end
  end
end
