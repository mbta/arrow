defmodule Arrow.Disruption.PublishedAfterReadyError do
  @moduledoc """
  An error representing an attempt to publish a revision of a disruption which
  has not been "readied" (approved) yet.
  """

  defexception [:message]

  @impl true
  def exception(_opts) do
    %__MODULE__{
      message: "Attempted to set published_revision_id greater than ready_revision_id"
    }
  end
end

defmodule Arrow.Disruption.ReadyNotLatestError do
  @moduledoc """
  An error representing an attempt to set the ready_revision_id higher than the
  latest revision.
  """

  defexception [:message]

  @impl true
  def exception(_opts) do
    %__MODULE__{
      message: "Attempted to set ready_revision_id greater than the lastest revision"
    }
  end
end
