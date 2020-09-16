defmodule Arrow.Disruption.PublishedAfterReadyError do
  defexception [:message]

  @impl true
  def exception(_opts) do
    %__MODULE__{message: "Attempted to set published_revision_id greater than ready_revision_id"}
  end
end
