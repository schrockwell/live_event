defmodule LiveEvent.LiveView do
  @moduledoc """
  Add LiveEvent support to LiveViews.

  Simply add

      use LiveEvent.LiveView

  to your LiveView module. See `LiveEvent` for more information on how to emit and handle events.

  The macro imports `LiveEvent.emit/3` and hooks into the LiveView lifecycle to
  add support for the `c:LiveEvent.handle_event/4` callback.
  """

  import LiveEvent.Internal

  defmacro __using__(_) do
    quote do
      @behaviour LiveEvent
      on_mount({LiveEvent.LiveView, __MODULE__})
      import LiveEvent, only: [emit: 2, emit: 3]
    end
  end

  @doc false
  def on_mount(module, _params, _session, socket) do
    {:cont,
     socket
     |> put_module(module)
     |> Phoenix.LiveView.attach_hook(
       :live_event_info,
       :handle_info,
       &handle_info/2
     )}
  end

  defp handle_info(%LiveEvent.Event{} = event, socket) do
    {:halt,
     get_module(socket).handle_event(
       event.name,
       event.source,
       event.payload,
       socket
     )}
  end

  defp handle_info(_message, socket), do: {:cont, socket}
end
