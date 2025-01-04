defmodule ArrowWeb.Flash do

  def put_flash!(socket, type, message) do
    send(self(), {:put_flash, type, message})
    socket
  end

end 
