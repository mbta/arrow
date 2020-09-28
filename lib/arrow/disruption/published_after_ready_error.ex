defmodule Arrow.Disruption.Error do
  defmodule PublishedAfterReady do
    defexception [:message]

    @impl true
    def exception(_opts) do
      %__MODULE__{
        message: "Attempted to set published_revision_id greater than ready_revision_id"
      }
    end
  end

  defmodule ReadyNotLatest do
    defexception [:message]

    @impl true
    def exception(_opts) do
      %__MODULE__{
        message: "Attempted to set ready_revision_id greater than the lastest revision"
      }
    end
  end
end
