defmodule Arrow.DraftsTest do
  use Arrow.DataCase
  alias Arrow.Adjustment
  alias Arrow.Disruption
  alias Arrow.Disruption.DayOfWeek
  alias Arrow.Repo
  import Ecto.Query, only: [from: 2]

  setup do
    adj = %Adjustment{
      source: "testing",
      source_label: "test_insert_disruption",
      route_id: "test_route"
    }

    Repo.insert!(adj)
    %{adjustments: Repo.all(from(Adjustment, []))}
  end

  test "Creating a new disruption puts it in draft state", %{adjustments: adjustments} do
    data = sample_data()
    _ = Disruption.create_draft(data, adjustments, "gabe")

    assert Disruption.get_all_published() == []
    assert [draft] = Disruption.get_all_drafts()
    assert_matches_data(draft, data)
  end

  test "A draft disruption can be published", %{adjustments: adjustments} do
    data = sample_data()
    _ = Disruption.create_draft(data, adjustments, "gabe")
    assert Disruption.get_all_published() == []
    _ = Disruption.publish()

    assert [pub] = Disruption.get_all_published()
    assert [draft] = Disruption.get_all_drafts()
    assert pub == draft
    assert_matches_data(pub, data)
  end

  test "A published disruption can be edited and then published", %{adjustments: adjustments} do
    data = sample_data()
    _ = Disruption.create_draft(data, adjustments, "gabe")
    _ = Disruption.publish()
    [disruption] = Disruption.get_all_published()
    id = Disruption.identifier(disruption)

    new_data = put_in(sample_data(), ["end_date"], ~D[2021-03-01])
    _ = Disruption.edit_draft(id, new_data, adjustments, "gabe")

    assert [draft] = Disruption.get_all_drafts()
    assert_matches_data(draft, new_data)
    assert [pub] = Disruption.get_all_published()
    assert_matches_data(pub, data)

    _ = Disruption.publish()
    assert [pub] = Disruption.get_all_published()
    assert [draft] = Disruption.get_all_drafts()
    assert pub == draft
    assert_matches_data(pub, new_data)
  end

  test "A draft disruption can be further edited", %{adjustments: adjustments} do
    data = sample_data()
    _ = Disruption.create_draft(data, adjustments, "gabe")
    [disruption] = Disruption.get_all_drafts()
    id = Disruption.identifier(disruption)

    new_data =
      update_in(data, ["exceptions"], fn exs -> [%{"excluded_date" => ~D[2021-01-11]} | exs] end)

    _ = Disruption.edit_draft(id, new_data, adjustments, "gabe")

    assert Disruption.get_all_published() == []
    assert [draft] = Disruption.get_all_drafts()
    assert_matches_data(draft, new_data)
  end

  test "A disruption can be deleted", %{adjustments: adjustments} do
    data = sample_data()
    _ = Disruption.create_draft(data, adjustments, "gabe")
    _ = Disruption.publish()
    [disruption] = Disruption.get_all_published()
    id = Disruption.identifier(disruption)

    _ = Disruption.delete(id, "gabe")
    assert length(Disruption.get_all_published()) == 1
    assert Disruption.get_all_drafts() == []

    _ = Disruption.publish()
    assert Disruption.get_all_published() == []
  end

  test "A diff can be produced, with attribution", %{adjustments: adjustments} do
    data1 = sample_data()
    _ = Disruption.create_draft(data1, adjustments, "gabe")
    _ = Disruption.publish()
    [id1] = Disruption.get_all_published() |> Enum.map(&Disruption.identifier/1)

    data2 = sample_data2()
    _ = Disruption.create_draft(data2, adjustments, "gabe")
    _ = Disruption.publish()
    ids = Disruption.get_all_published() |> Enum.map(&Disruption.identifier/1)
    id2 = Enum.find(ids, fn id -> id != id1 end)

    # delete first disruption
    _ = Disruption.delete(id1, "harry")

    # update second disruption's day of week
    data2a = put_in(data2, ["days_of_week", Access.at(0), "start_time"], ~T[11:00:00])
    {:ok, id2a} = Disruption.edit_draft(id2, data2a, adjustments, "ron")

    # add exception date to second disruption
    data2b =
      update_in(data2a, ["exceptions"], fn exs -> [%{"excluded_date" => ~D[2021-03-15]} | exs] end)

    _ = Disruption.edit_draft(id2a, data2b, adjustments, "hermione")

    # create a third disruption
    data3 = sample_data3()
    _ = Disruption.create_draft(data3, adjustments, "hagrid")

    diffs = Disruption.draft_diffs()
    assert length(diffs) == 4
    assert {id1, "deleted", "harry"} in diffs
    assert {id2, "monday start_time 12:00:00 -> 11:00:00", "ron"} in diffs
    assert {id2, "new exception date 2021-03-15", "hermione"} in diffs

    assert Enum.find(diffs, fn {_id, msg, author} ->
             author == "hagrid" and msg =~ "new disruption"
           end)
  end

  defp sample_data do
    %{
      "start_date" => ~D[2021-01-01],
      "end_date" => ~D[2021-02-01],
      "days_of_week" => [
        %{"day_name" => "monday", "start_time" => ~T[12:00:00], "end_time" => ~T[20:00:00]}
      ],
      "exceptions" => [%{"excluded_date" => ~D[2021-01-04]}]
    }
  end

  defp sample_data2 do
    %{
      "start_date" => ~D[2021-03-01],
      "end_date" => ~D[2021-05-01],
      "days_of_week" => [
        %{"day_name" => "monday", "start_time" => ~T[12:00:00], "end_time" => ~T[20:00:00]}
      ],
      "exceptions" => [%{"excluded_date" => ~D[2021-03-08]}]
    }
  end

  defp sample_data3 do
    %{
      "start_date" => ~D[2021-06-01],
      "end_date" => ~D[2021-07-01],
      "days_of_week" => [
        %{"day_name" => "monday", "start_time" => ~T[12:00:00], "end_time" => ~T[20:00:00]}
      ],
      "exceptions" => [%{"excluded_date" => ~D[2021-07-05]}]
    }
  end

  defp assert_matches_data(disruption, data) do
    assert disruption.start_date == data["start_date"]
    assert disruption.end_date == data["end_date"]

    assert length(disruption.days_of_week) == length(data["days_of_week"])

    Enum.each(data["days_of_week"], fn dow ->
      ddow = Enum.find(disruption.days_of_week, &(&1.day_name == dow["day_name"]))
      assert ddow.start_time == dow["start_time"]
      assert ddow.end_time == dow["end_time"]
    end)

    assert length(disruption.exceptions) == length(data["exceptions"])

    Enum.each(data["exceptions"], fn exc ->
      assert Enum.find(disruption.exceptions, &(&1.excluded_date == exc["excluded_date"]))
    end)
  end
end
