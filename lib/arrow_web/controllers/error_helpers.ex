defmodule ArrowWeb.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  use Phoenix.HTML

  @doc """
  Generates tag for inlined form input errors.
  """
  def error_tag(form, field) do
    Enum.map(Keyword.get_values(form.errors, field), fn error ->
      content_tag(:span, translate_error(error), class: "help-block")
    end)
  end

  @doc """
  Takes a changeset and returns a list of all its error messages.
  """
  @spec changeset_error_messages(Ecto.Changeset.t()) :: [String.t()]
  def changeset_error_messages(changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(&translate_error/1)
    |> flatten_errors()
  end

  @spec flatten_errors(map) :: list
  @doc """
  Converts a nested error map as returned from `Ecto.Changeset.traverse_errors/1` into a flat list
  of error messages.
  """
  def flatten_errors(errors) when is_map(errors) do
    errors |> Enum.flat_map(&error_messages/1) |> Enum.sort()
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(ArrowWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(ArrowWeb.Gettext, "errors", msg, opts)
    end
  end

  defp error_messages(field_errors, context \\ [])
  defp error_messages({_field, []}, _context), do: []

  defp error_messages({field, [error | rest]}, context) when is_binary(error) do
    field_description =
      [field | context]
      |> Enum.reverse()
      |> Enum.map_join(": ", &(&1 |> to_string() |> String.replace("_", " ")))
      |> String.capitalize()

    ["#{field_description} #{error}" | error_messages({field, rest}, context)]
  end

  defp error_messages({field, [errors | rest]}, context) when is_map(errors) do
    Enum.flat_map(errors, &error_messages(&1, [field | context])) ++
      error_messages({field, rest}, context)
  end
end
