defmodule Arrow.Util.Validation do
  @moduledoc """
  Utilities for validating changesets in Arrow. Note that many these functions make assumptions
  about the field names / error messages in your changeset that are specific to this project.
  """
  @spec validate_start_date_before_end_date(Ecto.Changeset.t(any())) :: Ecto.Changeset.t(any())
  def validate_start_date_before_end_date(changeset) do
    start_date = Ecto.Changeset.get_field(changeset, :start_date)
    end_date = Ecto.Changeset.get_field(changeset, :end_date)

    cond do
      is_nil(start_date) or is_nil(end_date) ->
        changeset

      Date.compare(start_date, end_date) == :gt ->
        Ecto.Changeset.add_error(
          changeset,
          :start_date,
          "start date must be less than or equal to end date"
        )

      true ->
        changeset
    end
  end
end
