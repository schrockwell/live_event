defmodule LiveEvent.Internal do
  @moduledoc false

  alias Phoenix.LiveView.Socket

  def put_module(%Socket{} = socket, module) do
    Map.update!(socket, :private, fn p -> Map.put(p, :live_event_module, module) end)
  end

  def get_module(%Socket{} = socket), do: socket.private.live_event_module
end
