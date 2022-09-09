defmodule LiveEvents.Internal do
  @moduledoc false

  alias Phoenix.LiveView.Socket

  def put_module(%Socket{} = socket, module) do
    Map.update!(socket, :private, fn p -> Map.put(p, :live_events_module, module) end)
  end

  def get_module(%Socket{} = socket), do: socket.private.live_events_module
end
