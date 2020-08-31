defmodule Arrow.DisruptionDiff do
  defstruct id: nil,
            latest_revision: nil,
            created?: false,
            diffs: []
end
