defmodule Arrow.Validations do
  import Ecto.Changeset

  @doc "Validates that the given changeset's field is not changing _to_ a date before today"
  @spec validate_not_in_past(Ecto.Changeset.t(), atom(), Date.t()) :: Ecto.Changeset.t()
  def validate_not_in_past(changeset, field, today) do
    validate_change(changeset, field, fn ^field, date ->
      if Date.compare(date, today) == :lt do
        [{field, "can't be in the past."}]
      else
        []
      end
    end)
  end

  @doc "Validates that the given changeset's field is not changing _from_ a date before today"
  @spec validate_not_changing_past(Ecto.Changeset.t(), atom(), Date.t()) :: Ecto.Changeset.t()
  def validate_not_changing_past(changeset, field, today) do
    current_date_val = Map.get(changeset.data, field)

    if not is_nil(current_date_val) and Date.compare(current_date_val, today) == :lt and
         not is_nil(get_change(changeset, field)) do
      add_error(changeset, field, "can't be changed in the past.")
    else
      changeset
    end
  end
end
