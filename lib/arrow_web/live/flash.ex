defmodule ArrowWeb.Flash do
  @moduledoc """
  Methods that allow live components to send "flash" messages to their parent live views
  """
  def put_flash!(socket, type, message) do
    send(self(), {:put_flash, type, message})
    socket
  end
end
