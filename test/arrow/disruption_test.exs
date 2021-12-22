defmodule Arrow.DisruptionTest do
  @moduledoc false
  use Arrow.DataCase
  import Ecto.Query
  alias Arrow.Disruption
  alias Arrow.Disruption.DayOfWeek
  alias Arrow.DisruptionRevision
  alias Arrow.Repo

  describe "database" do
    test "defaults to no disruptions" do
      assert [] = Repo.all(Disruption)
    end
  end

  describe "get!/1" do
    test "gets a disruption by ID with its latest revision and sorted associations" do
      %{id: id} = disruption = insert(:disruption)
      _old_revision = insert(:disruption_revision, disruption: disruption)

      %{id: latest_revision_id} =
        insert(:disruption_revision,
          disruption: disruption,
          adjustments: [
            build(:adjustment, source_label: "B"),
            build(:adjustment, source_label: "A"),
            build(:adjustment, source_label: "C")
          ],
          days_of_week: [build(:day_of_week, day_name: "monday")],
          exceptions: [
            build(:exception, excluded_date: ~D[2021-01-02]),
            build(:exception, excluded_date: ~D[2021-01-01]),
            build(:exception, excluded_date: ~D[2021-01-03])
          ],
          trip_short_names: [
            build(:trip_short_name, trip_short_name: "B"),
            build(:trip_short_name, trip_short_name: "A"),
            build(:trip_short_name, trip_short_name: "C")
          ]
        )

      assert %{
               id: ^id,
               revisions: [
                 %{
                   id: ^latest_revision_id,
                   adjustments: [
                     %{source_label: "A"},
                     %{source_label: "B"},
                     %{source_label: "C"}
                   ],
                   days_of_week: [%{day_name: "monday"}],
                   exceptions: [
                     %{excluded_date: ~D[2021-01-01]},
                     %{excluded_date: ~D[2021-01-02]},
                     %{excluded_date: ~D[2021-01-03]}
                   ],
                   trip_short_names: [
                     %{trip_short_name: "A"},
                     %{trip_short_name: "B"},
                     %{trip_short_name: "C"}
                   ]
                 }
               ]
             } = Disruption.get!(id)
    end
  end

  describe "create/1" do
    test "inserts a new disruption and revision" do
      attrs = %{
        "start_date" => "2021-01-01",
        "end_date" => "2021-12-31",
        "row_approved" => "true",
        "adjustments" => [%{"id" => insert(:adjustment).id}],
        "days_of_week" => [%{"day_name" => "monday", "start_time" => "20:00:00"}],
        "exceptions" => [%{"excluded_date" => "2021-01-11"}],
        "trip_short_names" => [%{"trip_short_name" => "777"}],
        "description" => "a testing disruption"
      }

      {:ok, _id} = Disruption.create(attrs)

      [d] = Repo.all(Disruption)

      [dr] =
        DisruptionRevision
        |> Repo.all()
        |> Repo.preload(DisruptionRevision.associations())

      assert dr.disruption_id == d.id
      assert dr.start_date == ~D[2021-01-01]
      assert dr.end_date == ~D[2021-12-31]
      assert dr.row_approved == true
      assert dr.description == "a testing disruption"

      assert [%DayOfWeek{day_name: "monday", start_time: ~T[20:00:00], end_time: nil}] =
               dr.days_of_week

      assert [%Disruption.Exception{excluded_date: ~D[2021-01-11]}] = dr.exceptions
      assert [%Disruption.TripShortName{trip_short_name: "777"}] = dr.trip_short_names
    end

    test "can't create disruption with start date after end date" do
      attrs = %{
        "start_date" => "2020-12-31",
        "end_date" => "2020-01-01",
        "days_of_week" => [%{"day_name" => "monday"}]
      }

      {:error, changeset} = Disruption.create(attrs)

      assert "can't be after end date" in errors_on(changeset).start_date
    end

    test "can't create disruption with day of week outside date range" do
      attrs = %{
        "start_date" => "2020-08-17",
        "end_date" => "2020-08-21",
        "days_of_week" => [%{"day_name" => "sunday"}]
      }

      {:error, changeset} = Disruption.create(attrs)

      assert "should fall between start and end dates" in errors_on(changeset).days_of_week
    end

    test "can't create disruption with exception date outside date range" do
      attrs = %{
        "start_date" => "2020-08-17",
        "end_date" => "2020-08-21",
        "days_of_week" => [%{"day_name" => "tuesday"}],
        "exceptions" => [%{"excluded_date" => "2020-09-01"}]
      }

      {:error, changeset} = Disruption.create(attrs)

      assert "should fall between start and end dates" in errors_on(changeset).exceptions
    end

    test "can't create disruption with duplicate exception dates" do
      attrs = %{
        "start_date" => "2020-08-17",
        "end_date" => "2020-08-21",
        "days_of_week" => [%{"day_name" => "tuesday"}],
        "exceptions" => [%{"excluded_date" => "2020-08-18"}, %{"excluded_date" => "2020-08-18"}]
      }

      {:error, changeset} = Disruption.create(attrs)

      assert "should be unique" in errors_on(changeset).exceptions
    end

    test "can't create disruption with exception dates that don't apply to day of week" do
      attrs = %{
        "start_date" => "2020-08-17",
        "end_date" => "2020-08-21",
        "days_of_week" => [%{"day_name" => "tuesday"}],
        "exceptions" => [%{"excluded_date" => "2020-08-19"}]
      }

      {:error, changeset} = Disruption.create(attrs)

      assert "should be applicable to days of week" in errors_on(changeset).exceptions
    end

    test "can't create disruption without days of week" do
      attrs = %{"start_date" => "2020-08-17", "end_date" => "2020-08-21"}

      {:error, changeset} = Disruption.create(attrs)

      assert "must be selected" in errors_on(changeset).days_of_week
    end

    test "requires exactly one of adjustment kind or non-empty adjustments" do
      {:error, changeset} = Disruption.create(%{"adjustment_kind" => nil, "adjustments" => []})
      assert "is required without adjustments" in errors_on(changeset).adjustment_kind

      {:error, changeset} =
        Disruption.create(%{
          "adjustment_kind" => "red_line",
          "adjustments" => [%{"id" => insert(:adjustment).id}]
        })

      assert "cannot be set with adjustments" in errors_on(changeset).adjustment_kind
    end
  end

  describe "update/2" do
    test "creates a new disruption revision" do
      %{id: id} = disruption = insert(:disruption)

      %{id: dr_id} =
        insert(:disruption_revision, %{
          disruption: disruption,
          start_date: ~D[2021-01-01],
          end_date: ~D[2021-12-31],
          days_of_week: [build(:day_of_week, %{day_name: "monday"})],
          exceptions: [build(:exception, %{excluded_date: ~D[2021-01-11]})],
          trip_short_names: [build(:trip_short_name, %{trip_short_name: "777"})]
        })

      attrs = %{
        "start_date" => "2021-01-01",
        "end_date" => "2021-11-30",
        "row_approved" => false,
        "days_of_week" => [%{"day_name" => "monday", "start_time" => "20:45:00"}],
        "exceptions" => [%{"excluded_date" => "2021-01-11"}, %{"excluded_date" => "2021-01-18"}],
        "trip_short_names" => [%{"trip_short_name" => "777"}, %{"trip_short_name" => "888"}]
      }

      {:ok, _id} = Disruption.update(id, attrs)

      dr_ids = Repo.all(from(dr in DisruptionRevision, select: dr.id))
      assert length(dr_ids) == 2
      new_dr_id = Enum.find(dr_ids, &(&1 != dr_id))

      new_dr =
        DisruptionRevision
        |> Repo.get!(new_dr_id)
        |> Repo.preload(DisruptionRevision.associations())

      assert new_dr.disruption_id == id
      assert new_dr.is_active
      assert new_dr.start_date == ~D[2021-01-01]
      assert new_dr.end_date == ~D[2021-11-30]
      assert new_dr.row_approved == false

      assert [%DayOfWeek{day_name: "monday", start_time: ~T[20:45:00], end_time: nil}] =
               new_dr.days_of_week

      assert Enum.find(new_dr.exceptions, &(&1.excluded_date == ~D[2021-01-11]))
      assert Enum.find(new_dr.exceptions, &(&1.excluded_date == ~D[2021-01-18]))
      assert Enum.find(new_dr.trip_short_names, &(&1.trip_short_name == "777"))
      assert Enum.find(new_dr.trip_short_names, &(&1.trip_short_name == "888"))
    end

    test "doesn't create a new revision if there is a validation error" do
      %{disruption_id: id} = insert(:disruption_revision)

      {:error, _} = Disruption.update(id, %{start_date: nil})

      assert Repo.one!(DisruptionRevision)
    end

    test "can't update disruption with start date after end date" do
      %{disruption_id: id} =
        insert(:disruption_revision, %{
          start_date: ~D[2020-08-17],
          end_date: ~D[2020-08-21],
          days_of_week: [build(:day_of_week, %{day_name: "tuesday"})]
        })

      attrs = %{
        "start_date" => "2020-12-31",
        "end_date" => "2020-01-01",
        "days_of_week" => [%{"day_name" => "tuesday"}]
      }

      {:error, changeset} = Disruption.update(id, attrs)

      assert "can't be after end date" in errors_on(changeset).start_date
    end

    test "can't update disruption with day of week outside date range" do
      %{disruption_id: id} =
        insert(:disruption_revision, %{
          start_date: ~D[2020-08-17],
          end_date: ~D[2020-08-21],
          days_of_week: [build(:day_of_week, %{day_name: "tuesday"})]
        })

      attrs = %{
        "start_date" => "2020-08-17",
        "end_date" => "2020-08-21",
        "days_of_week" => [%{"day_name" => "sunday"}]
      }

      {:error, changeset} = Disruption.update(id, attrs)

      assert "should fall between start and end dates" in errors_on(changeset).days_of_week
    end

    test "can't update disruption with exception date outside date range" do
      %{disruption_id: id} =
        insert(:disruption_revision, %{
          start_date: ~D[2020-08-17],
          end_date: ~D[2020-08-21],
          days_of_week: [build(:day_of_week, %{day_name: "tuesday"})]
        })

      attrs = %{
        "start_date" => "2020-08-17",
        "end_date" => "2020-08-21",
        "days_of_week" => [%{"day_name" => "tuesday"}],
        "exceptions" => [%{"excluded_date" => "2020-09-01"}]
      }

      {:error, changeset} = Disruption.update(id, attrs)

      assert "should fall between start and end dates" in errors_on(changeset).exceptions
    end

    test "can't update disruption with duplicate exception dates" do
      %{disruption_id: id} =
        insert(:disruption_revision, %{
          start_date: ~D[2020-08-17],
          end_date: ~D[2020-08-21],
          days_of_week: [build(:day_of_week, %{day_name: "tuesday"})]
        })

      attrs = %{
        "start_date" => "2020-08-17",
        "end_date" => "2020-08-21",
        "days_of_week" => [%{"day_name" => "tuesday"}],
        "exceptions" => [%{"excluded_date" => "2020-08-18"}, %{"excluded_date" => "2020-08-18"}]
      }

      {:error, changeset} = Disruption.update(id, attrs)

      assert "should be unique" in errors_on(changeset).exceptions
    end

    test "can't update disruption with exception dates that don't apply to day of week" do
      %{disruption_id: id} =
        insert(:disruption_revision, %{
          start_date: ~D[2020-08-17],
          end_date: ~D[2020-08-21],
          days_of_week: [build(:day_of_week, %{day_name: "tuesday"})]
        })

      attrs = %{
        "start_date" => "2020-08-17",
        "end_date" => "2020-08-21",
        "days_of_week" => [%{"day_name" => "tuesday"}],
        "exceptions" => [%{"excluded_date" => "2020-08-19"}]
      }

      {:error, changeset} = Disruption.update(id, attrs)

      assert "should be applicable to days of week" in errors_on(changeset).exceptions
    end

    test "can't update disruption to remove all days of week" do
      %{disruption_id: id} =
        insert(:disruption_revision, %{
          start_date: ~D[2020-08-17],
          end_date: ~D[2020-08-21],
          days_of_week: [build(:day_of_week, %{day_name: "tuesday"})]
        })

      attrs = %{
        "start_date" => "2020-08-17",
        "end_date" => "2020-08-21",
        "days_of_week" => []
      }

      {:error, changeset} = Disruption.update(id, attrs)

      assert "must be selected" in errors_on(changeset).days_of_week
    end

    test "requires exactly one of adjustment kind or non-empty adjustments" do
      %{disruption_id: kind_id} = insert(:disruption_revision, adjustment_kind: :bus)
      %{disruption_id: adj_id} = insert(:disruption_revision, adjustments: [build(:adjustment)])

      {:error, changeset} = Disruption.update(kind_id, %{"adjustment_kind" => nil})
      assert "is required without adjustments" in errors_on(changeset).adjustment_kind

      {:error, changeset} = Disruption.update(adj_id, %{"adjustments" => []})
      assert "is required without adjustments" in errors_on(changeset).adjustment_kind

      %{id: id} = insert(:adjustment)
      {:error, changeset} = Disruption.update(kind_id, %{"adjustments" => [%{"id" => id}]})
      assert "cannot be set with adjustments" in errors_on(changeset).adjustment_kind

      {:error, changeset} = Disruption.update(adj_id, %{"adjustment_kind" => "bus"})
      assert "cannot be set with adjustments" in errors_on(changeset).adjustment_kind
    end
  end

  describe "delete!/1" do
    test "creates a new revision which isn't active" do
      d = insert(:disruption)

      insert(:disruption_revision, %{
        disruption: d,
        start_date: ~D[2020-08-17],
        end_date: ~D[2020-08-21],
        days_of_week: [build(:day_of_week, %{day_name: "tuesday"})]
      })

      new_revision = Disruption.delete!(d.id)

      assert Repo.all(from(dr in DisruptionRevision, select: count(dr.id))) == [2]
      assert new_revision.is_active == false
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
