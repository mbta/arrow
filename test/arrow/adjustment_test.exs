defmodule Arrow.AdjustmentTest do
  @moduledoc false
  use Arrow.DataCase
  alias Arrow.Adjustment
  alias Arrow.Repo

  describe "database" do
    test "can insert an adjustment" do
      adj = %Adjustment{
        source: "testing",
        source_label: "test_insert_adjustment",
        route_id: "test_route"
      }

      assert {:ok, new_adj} = Repo.insert(adj)
      assert adj.source == new_adj.source
      assert adj.source_label == new_adj.source_label
      assert adj.route_id == new_adj.route_id

      assert new_adj in Repo.all(Adjustment)
    end

    test "source_label is unique" do
      adj1 = %Adjustment{
        source: "testing1",
        source_label: "test_unique_source_label",
        route_id: "test_route"
      }

      adj2 = %Adjustment{
        source: "testing2",
        source_label: "test_unique_source_label",
        route_id: "test_route"
      }

      assert {:ok, _} = Repo.insert(adj1)
      assert {:error, _} = Repo.insert(Adjustment.changeset(adj2, %{}))
    end
  end

  describe "from_revision_attrs/1" do
    test "fetches adjustments for DisruptionRevision changeset params" do
      [%{id: id1}, _, %{id: id2}] = insert_list(3, :adjustment)
      attrs = %{"adjustments" => [%{"id" => "#{id1}"}, %{"id" => "#{id2}"}]}

      adjustments = Adjustment.from_revision_attrs(attrs)

      assert [%Adjustment{id: ^id1}, %Adjustment{id: ^id2}] = adjustments
    end
  end
end
