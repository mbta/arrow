defmodule Arrow.Disruption.NoteTest do
  use ExUnit.Case, async: true

  alias Arrow.Disruption.Note

  describe "changeset" do
    test "valid with all the data" do
      changeset = Note.changeset(10, "author", %{"body" => "this is the body"})
      assert changeset.valid?
    end

    test "invalid without body" do
      changeset = Note.changeset(10, "author", %{})
      refute changeset.valid?
      assert Keyword.get(changeset.errors, :body)
    end
  end
end
