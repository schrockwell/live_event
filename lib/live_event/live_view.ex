defmodule LiveEvent.LiveView do
  @moduledoc """
  Add LiveEvent support to LiveViews.

  Simply add

      use LiveEvent.LiveView

  to your LiveView module. See `LiveEvent` for more information on how to emit and handle events.

  The macro imports `LiveEvent.emit/2` and hooks into the LiveView lifecycle to
  add support for the `c:LiveEvent.handle_emit/2` callback.
  """

  defmacro __using__(_) do
    quote do
      @behaviour LiveEvent
      on_mount({LiveEvent.LiveView, __MODULE__})
      import LiveEvent, only: [emit: 2]
    end
  end

  @doc false
  def on_mount(module, _params, _session, socket) do
    {:cont,
     Phoenix.LiveView.attach_hook(
       socket,
       :live_event_info,
       :handle_info,
       &handle_info(module, &1, &2)
     )}
  end

  defp handle_info(module, %LiveEvent.Event{} = event, socket) do
    socket =
      case module.handle_emit(event.payload, socket) do
        {:ok, %Phoenix.LiveView.Socket{} = socket} -> socket
        _unexpected -> raise "expected handle_emit/2 to return {:ok, %LiveView.Socket{}}"
      end

    {:halt, socket}
  end

  defp handle_info(_module, _message, socket), do: {:cont, socket}
end
