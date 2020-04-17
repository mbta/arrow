defmodule Arrow.ValidationsTest do
  use Arrow.DataCase
  alias Arrow.Validations

  describe "validate_not_in_past/3" do
    test "invalid if date is in past" do
      changeset =
        Ecto.Changeset.cast(
          %Arrow.Disruption{},
          %{"start_date" => "2020-01-01"},
          [:start_date]
        )

      changeset = Validations.validate_not_in_past(changeset, :start_date, ~D[2020-04-01])
      assert %{start_date: ["can't be in the past."]} = errors_on(changeset)
    end

    test "valid if date is in past but not changing" do
      changeset =
        Ecto.Changeset.cast(
          %Arrow.Disruption{start_date: ~D[2020-01-01]},
          %{"start_date" => "2020-01-01"},
          [:start_date]
        )

      changeset = Validations.validate_not_in_past(changeset, :start_date, ~D[2020-04-01])
      assert changeset.valid?
    end
  end

  describe "validate_not_changing_past/3" do
    test "invalid if changing date from past" do
      changeset =
        Ecto.Changeset.cast(
          %Arrow.Disruption{start_date: ~D[2020-01-01]},
          %{"start_date" => "2020-12-01"},
          [:start_date]
        )

      changeset = Validations.validate_not_changing_past(changeset, :start_date, ~D[2020-04-01])

      assert %{start_date: ["can't be changed in the past."]} = errors_on(changeset)
    end

    test "valid if not changing date from past to future" do
      changeset =
        Ecto.Changeset.cast(%Arrow.Disruption{}, %{"start_date" => "2020-12-01"}, [:start_date])

      changeset = Validations.validate_not_changing_past(changeset, :start_date, ~D[2020-04-01])

      assert changeset.valid?
    end
  end
end
