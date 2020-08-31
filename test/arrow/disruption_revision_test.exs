defmodule Arrow.DisruptionRevisionTest do
  @moduledoc false
  use Arrow.DataCase
  alias Arrow.DisruptionRevision
  import Ecto.Query

  describe "only_published/1" do
    test "returns nothing when published revision of a disruption is deleted" do
      dr1 = insert(:disruption_revision) |> Arrow.Repo.preload([:disruption])

      :ok = DisruptionRevision.publish_all!()

      {:ok, _dr2} = Arrow.Disruption.delete(dr1.id)

      :ok = DisruptionRevision.publish_all!()

      published_dr =
        DisruptionRevision
        |> DisruptionRevision.only_published()
        |> Repo.get_by(disruption_id: dr1.disruption.id)

      assert is_nil(published_dr)
    end
  end

  describe "latest_revision/1" do
    test "returns nothing when latest revision of a disruption is deleted" do
      dr1 = insert(:disruption_revision) |> Arrow.Repo.preload([:disruption])

      :ok = DisruptionRevision.publish_all!()

      {:ok, _dr2} = Arrow.Disruption.delete(dr1.id)

      published_dr =
        DisruptionRevision
        |> DisruptionRevision.latest_revision()
        |> Repo.get_by(disruption_id: dr1.disruption.id)

      assert is_nil(published_dr)
    end
  end

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

  describe "only_published/1 and latest_revision/1" do
    test "Returns the respective views of the disruption" do
      d = insert(:disruption)
      dr1 = insert(:disruption_revision, %{disruption: d})
      d |> Ecto.Changeset.change(%{published_revision_id: dr1.id}) |> Repo.update!()
      _dr2 = insert(:disruption_revision, %{disruption: d})
      dr3 = insert(:disruption_revision, %{disruption: d})

      base = from(d in Arrow.DisruptionRevision)

      published_id = dr1.id
      draft_id = dr3.id

      assert [
               %{id: ^published_id}
             ] = base |> Arrow.DisruptionRevision.only_published() |> Repo.all()

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
