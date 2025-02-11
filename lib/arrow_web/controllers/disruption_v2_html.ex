defmodule ArrowWeb.DisruptionV2View do
  use ArrowWeb, :html

  alias Arrow.Permissions
  alias Phoenix.Controller

  embed_templates "disruption_v2_html/*"
end
