defmodule Arrow.DisruptionTest do
  @moduledoc false
  use Arrow.DataCase
  alias Arrow.Disruption
  alias Arrow.DisruptionRevision
  alias Arrow.Repo

  describe "database" do
    test "defaults to no disruptions" do
      assert [] = Repo.all(Disruption)
    end
  end

  describe "create/2" do
    test "inserts a new disruption and revision" do
      adj = insert(:adjustment)

      attrs = %{
        "start_date" => "2021-01-01",
        "end_date" => "2021-12-31",
        "days_of_week" => [%{"day_name" => "monday", "start_time" => "20:00:00"}],
        "exceptions" => [%{"excluded_date" => "2021-01-11"}],
        "trip_short_names" => [%{"trip_short_name" => "777"}]
      }

      assert {:ok, _dr} = Arrow.Disruption.create(attrs, [adj])

      [d] = Repo.all(Arrow.Disruption)

      [dr] =
        DisruptionRevision
        |> Repo.all()
        |> Repo.preload(DisruptionRevision.associations())

      assert dr.disruption_id == d.id
      assert dr.start_date == ~D[2021-01-01]
      assert dr.end_date == ~D[2021-12-31]

      assert [
               %Arrow.Disruption.DayOfWeek{
                 day_name: "monday",
                 start_time: ~T[20:00:00],
                 end_time: nil
               }
             ] = dr.days_of_week

      assert [%Arrow.Disruption.Exception{excluded_date: ~D[2021-01-11]}] = dr.exceptions
      assert [%Arrow.Disruption.TripShortName{trip_short_name: "777"}] = dr.trip_short_names
    end

    test "can't create disruption with start date after end date" do
      adj = insert(:adjustment)

      attrs = %{
        "start_date" => "2020-12-31",
        "end_date" => "2020-01-01",
        "days_of_week" => [%{"day_name" => "monday"}]
      }

      assert {:error, e} = Arrow.Disruption.create(attrs, [adj])

      assert [
               %{detail: "Start date can't be after end date."}
             ] = ArrowWeb.Utilities.format_errors(e)
    end

    test "can't create disruption with day of week outside date range" do
      adj = insert(:adjustment)

      attrs = %{
        "start_date" => "2020-08-17",
        "end_date" => "2020-08-21",
        "days_of_week" => [%{"day_name" => "sunday"}]
      }

      assert {:error, e} = Arrow.Disruption.create(attrs, [adj])

      assert [
               %{detail: "Days of week should fall between start and end dates"}
             ] = ArrowWeb.Utilities.format_errors(e)
    end

    test "can't create disruption with exception date outside date range" do
      adj = insert(:adjustment)

      attrs = %{
        "start_date" => "2020-08-17",
        "end_date" => "2020-08-21",
        "days_of_week" => [%{"day_name" => "tuesday"}],
        "exceptions" => [%{"excluded_date" => "2020-09-01"}]
      }

      assert {:error, e} = Arrow.Disruption.create(attrs, [adj])

      assert [
               %{detail: "Exceptions should fall between start and end dates"}
             ] = ArrowWeb.Utilities.format_errors(e)
    end

    test "can't create disruption with duplicate exception dates" do
      adj = insert(:adjustment)

      attrs = %{
        "start_date" => "2020-08-17",
        "end_date" => "2020-08-21",
        "days_of_week" => [%{"day_name" => "tuesday"}],
        "exceptions" => [%{"excluded_date" => "2020-08-18"}, %{"excluded_date" => "2020-08-18"}]
      }

      assert {:error, e} = Arrow.Disruption.create(attrs, [adj])

      assert [
               %{detail: "Exceptions should be unique"}
             ] = ArrowWeb.Utilities.format_errors(e)
    end

    test "can't create disruption with exception dates that don't apply to day of week" do
      adj = insert(:adjustment)

      attrs = %{
        "start_date" => "2020-08-17",
        "end_date" => "2020-08-21",
        "days_of_week" => [%{"day_name" => "tuesday"}],
        "exceptions" => [%{"excluded_date" => "2020-08-19"}]
      }

      assert {:error, e} = Arrow.Disruption.create(attrs, [adj])

      assert [
               %{detail: "Exceptions should be applicable to days of week"}
             ] = ArrowWeb.Utilities.format_errors(e)
    end

    test "can't create disruption without days of week" do
      adj = insert(:adjustment)

      attrs = %{
        "start_date" => "2020-08-17",
        "end_date" => "2020-08-21"
      }

      assert {:error, e} = Arrow.Disruption.create(attrs, [adj])

      assert [
               %{detail: "Days of week should have at least 1 item(s)"}
             ] = ArrowWeb.Utilities.format_errors(e)
    end

    test "can't create disruption without adjustments" do
      attrs = %{
        "start_date" => "2020-08-17",
        "end_date" => "2020-08-21",
        "days_of_week" => [%{"day_name" => "tuesday"}]
      }

      assert {:error, e} = Arrow.Disruption.create(attrs, [])

      assert [
               %{detail: "Adjustments should have at least 1 item(s)"}
             ] = ArrowWeb.Utilities.format_errors(e)
    end
  end

  describe "update/2" do
    test "creates a new disruption revision" do
      d = insert(:disruption)

      dr =
        insert(:disruption_revision, %{
          disruption: d,
          start_date: ~D[2021-01-01],
          end_date: ~D[2021-12-31],
          days_of_week: [build(:day_of_week, %{day_name: "monday"})],
          exceptions: [build(:exception, %{excluded_date: ~D[2021-01-11]})],
          trip_short_names: [build(:trip_short_name, %{trip_short_name: "777"})]
        })

      Repo.update!(Ecto.Changeset.change(d, %{ready_revision_id: dr.id}))

      dr_id = dr.id

      new_attrs = %{
        "start_date" => "2021-01-01",
        "end_date" => "2021-11-30",
        "days_of_week" => [%{"day_name" => "monday", "start_time" => "20:45:00"}],
        "exceptions" => [%{"excluded_date" => "2021-01-11"}, %{"excluded_date" => "2021-01-18"}],
        "trip_short_names" => [%{"trip_short_name" => "777"}, %{"trip_short_name" => "888"}]
      }

      assert {:ok, _dr} = Arrow.Disruption.update(dr_id, new_attrs)

      dr_ids = Repo.all(Ecto.Query.from(dr in DisruptionRevision, select: dr.id))
      assert length(dr_ids) == 2
      new_dr_id = Enum.find(dr_ids, &(&1 != dr_id))

      new_dr =
        DisruptionRevision
        |> Repo.get!(new_dr_id)
        |> Repo.preload(DisruptionRevision.associations())

      d = Repo.get!(Arrow.Disruption, new_dr.disruption_id)

      assert new_dr.disruption_id == d.id
      assert d.ready_revision_id == dr_id
      assert new_dr.start_date == ~D[2021-01-01]
      assert new_dr.end_date == ~D[2021-11-30]

      assert [
               %Arrow.Disruption.DayOfWeek{
                 day_name: "monday",
                 start_time: ~T[20:45:00],
                 end_time: nil
               }
             ] = new_dr.days_of_week

      assert Enum.find(new_dr.exceptions, &(&1.excluded_date == ~D[2021-01-11]))
      assert Enum.find(new_dr.exceptions, &(&1.excluded_date == ~D[2021-01-18]))
      assert Enum.find(new_dr.trip_short_names, &(&1.trip_short_name == "777"))
      assert Enum.find(new_dr.trip_short_names, &(&1.trip_short_name == "888"))
    end

    test "can't update disruption with start date after end date" do
      d = insert(:disruption)

      dr =
        insert(:disruption_revision, %{
          disruption: d,
          start_date: ~D[2020-08-17],
          end_date: ~D[2020-08-21],
          days_of_week: [build(:day_of_week, %{day_name: "tuesday"})]
        })

      Repo.update!(Ecto.Changeset.change(d, %{ready_revision_id: dr.id}))

      attrs = %{
        "start_date" => "2020-12-31",
        "end_date" => "2020-01-01",
        "days_of_week" => [%{"day_name" => "tuesday"}]
      }

      assert {:error, e} = Arrow.Disruption.update(dr.id, attrs)

      assert [
               %{detail: "Start date can't be after end date."}
             ] = ArrowWeb.Utilities.format_errors(e)
    end

    test "can't update disruption with day of week outside date range" do
      d = insert(:disruption)

      dr =
        insert(:disruption_revision, %{
          disruption: d,
          start_date: ~D[2020-08-17],
          end_date: ~D[2020-08-21],
          days_of_week: [build(:day_of_week, %{day_name: "tuesday"})]
        })

      Repo.update!(Ecto.Changeset.change(d, %{ready_revision_id: dr.id}))

      attrs = %{
        "start_date" => "2020-08-17",
        "end_date" => "2020-08-21",
        "days_of_week" => [%{"day_name" => "sunday"}]
      }

      assert {:error, e} = Arrow.Disruption.update(dr.id, attrs)
      assert Repo.all(from(dr in DisruptionRevision, select: count(dr.id))) == [1]

      assert [
               %{detail: "Days of week should fall between start and end dates"}
             ] = ArrowWeb.Utilities.format_errors(e)
    end

    test "can't update disruption with exception date outside date range" do
      d = insert(:disruption)

      dr =
        insert(:disruption_revision, %{
          disruption: d,
          start_date: ~D[2020-08-17],
          end_date: ~D[2020-08-21],
          days_of_week: [build(:day_of_week, %{day_name: "tuesday"})]
        })

      Repo.update!(Ecto.Changeset.change(d, %{ready_revision_id: dr.id}))

      attrs = %{
        "start_date" => "2020-08-17",
        "end_date" => "2020-08-21",
        "days_of_week" => [%{"day_name" => "tuesday"}],
        "exceptions" => [%{"excluded_date" => "2020-09-01"}]
      }

      assert {:error, e} = Arrow.Disruption.update(dr.id, attrs)
      assert Repo.all(from(dr in DisruptionRevision, select: count(dr.id))) == [1]

      assert [
               %{detail: "Exceptions should fall between start and end dates"}
             ] = ArrowWeb.Utilities.format_errors(e)
    end

    test "can't update disruption with duplicate exception dates" do
      d = insert(:disruption)

      dr =
        insert(:disruption_revision, %{
          disruption: d,
          start_date: ~D[2020-08-17],
          end_date: ~D[2020-08-21],
          days_of_week: [build(:day_of_week, %{day_name: "tuesday"})]
        })

      Repo.update!(Ecto.Changeset.change(d, %{ready_revision_id: dr.id}))

      attrs = %{
        "start_date" => "2020-08-17",
        "end_date" => "2020-08-21",
        "days_of_week" => [%{"day_name" => "tuesday"}],
        "exceptions" => [%{"excluded_date" => "2020-08-18"}, %{"excluded_date" => "2020-08-18"}]
      }

      assert {:error, e} = Arrow.Disruption.update(dr.id, attrs)
      assert Repo.all(from(dr in DisruptionRevision, select: count(dr.id))) == [1]

      assert [
               %{detail: "Exceptions should be unique"}
             ] = ArrowWeb.Utilities.format_errors(e)
    end

    test "can't update disruption with exception dates that don't apply to day of week" do
      d = insert(:disruption)

      dr =
        insert(:disruption_revision, %{
          disruption: d,
          start_date: ~D[2020-08-17],
          end_date: ~D[2020-08-21],
          days_of_week: [build(:day_of_week, %{day_name: "tuesday"})]
        })

      Repo.update!(Ecto.Changeset.change(d, %{ready_revision_id: dr.id}))

      attrs = %{
        "start_date" => "2020-08-17",
        "end_date" => "2020-08-21",
        "days_of_week" => [%{"day_name" => "tuesday"}],
        "exceptions" => [%{"excluded_date" => "2020-08-19"}]
      }

      assert {:error, e} = Arrow.Disruption.update(dr.id, attrs)
      assert Repo.all(from(dr in DisruptionRevision, select: count(dr.id))) == [1]

      assert [
               %{detail: "Exceptions should be applicable to days of week"}
             ] = ArrowWeb.Utilities.format_errors(e)
    end

    test "can't update disruption to remove all days of week" do
      d = insert(:disruption)

      dr =
        insert(:disruption_revision, %{
          disruption: d,
          start_date: ~D[2020-08-17],
          end_date: ~D[2020-08-21],
          days_of_week: [build(:day_of_week, %{day_name: "tuesday"})]
        })

      Repo.update!(Ecto.Changeset.change(d, %{ready_revision_id: dr.id}))

      attrs = %{
        "start_date" => "2020-08-17",
        "end_date" => "2020-08-21",
        "days_of_week" => []
      }

      assert {:error, e} = Arrow.Disruption.update(dr.id, attrs)
      assert Repo.all(from(dr in DisruptionRevision, select: count(dr.id))) == [1]

      assert [
               %{detail: "Days of week should have at least 1 item(s)"}
             ] = ArrowWeb.Utilities.format_errors(e)
    end
  end

  describe "delete/1" do
    test "creates a new revision which isn't active" do
      d = insert(:disruption)

      dr1 =
        insert(:disruption_revision, %{
          disruption: d,
          start_date: ~D[2020-08-17],
          end_date: ~D[2020-08-21],
          days_of_week: [build(:day_of_week, %{day_name: "tuesday"})]
        })

      Repo.update!(Ecto.Changeset.change(d, %{ready_revision_id: dr1.id}))

      assert {:ok, dr2} = Arrow.Disruption.delete(dr1.id)

      d = Repo.get(Arrow.Disruption, d.id)

      assert Repo.all(from(dr in DisruptionRevision, select: count(dr.id))) == [2]
      assert dr2.is_active == false
      assert d.ready_revision_id == dr1.id
    end
  end

  describe "draft_vs_ready" do
    test "returns all revisions between draft and ready" do
      d = insert(:disruption)
      _dr1 = insert(:disruption_revision, %{disruption: d})
      dr2 = insert(:disruption_revision, %{disruption: d})
      dr3 = insert(:disruption_revision, %{disruption: d})
      dr4 = insert(:disruption_revision, %{disruption: d})
      Repo.update!(Ecto.Changeset.change(d, %{ready_revision_id: dr2.id}))

      dr2_id = dr2.id
      dr3_id = dr3.id
      dr4_id = dr4.id

      assert {[queried_d], []} = Arrow.Disruption.draft_vs_ready()
      assert queried_d.id == d.id

      assert [
               %DisruptionRevision{id: ^dr2_id},
               %DisruptionRevision{id: ^dr3_id},
               %DisruptionRevision{id: ^dr4_id}
             ] = queried_d.revisions
    end

    test "does not return a disruption without a different draft" do
      d = insert(:disruption)
      _dr1 = insert(:disruption_revision, %{disruption: d})
      dr2 = insert(:disruption_revision, %{disruption: d})
      Repo.update!(Ecto.Changeset.change(d, %{ready_revision_id: dr2.id}))

      assert Arrow.Disruption.draft_vs_ready() == {[], []}
    end

    test "returns a newly created disruption" do
      d = insert(:disruption)
      dr1 = insert(:disruption_revision, %{disruption: d})
      dr2 = insert(:disruption_revision, %{disruption: d})

      dr1_id = dr1.id
      dr2_id = dr2.id

      assert {[], [queried_d]} = Arrow.Disruption.draft_vs_ready()

      assert [%DisruptionRevision{id: ^dr1_id}, %DisruptionRevision{id: ^dr2_id}] =
               queried_d.revisions
    end
  end

  describe "latest_vs_published" do
    test "returns the latest revision and the published revision when there are both" do
      d = insert(:disruption)
      _dr1 = insert(:disruption_revision, %{disruption: d})
      dr2 = insert(:disruption_revision, %{disruption: d})
      _dr3 = insert(:disruption_revision, %{disruption: d})
      dr4 = insert(:disruption_revision, %{disruption: d})

      Repo.update!(Ecto.Changeset.change(d, %{published_revision_id: dr2.id}))

      assert [d] = Arrow.Disruption.latest_vs_published()

      revision_ids = Enum.map(d.revisions, & &1.id)
      assert length(revision_ids) == 2
      assert dr2.id in revision_ids
      assert dr4.id in revision_ids
    end

    test "returns just the latest revision if there is no published revision" do
      d = insert(:disruption)
      _dr1 = insert(:disruption_revision, %{disruption: d})
      dr2 = insert(:disruption_revision, %{disruption: d})

      assert [%Disruption{revisions: [%DisruptionRevision{id: id}]}] =
               Arrow.Disruption.latest_vs_published()

      assert id == dr2.id
    end
  end
end
