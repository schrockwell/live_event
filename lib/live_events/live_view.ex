defmodule LiveEvents.LiveView do
  @moduledoc """
  Add LiveEvent support to LiveViews.

  Simply add

      use LiveEvents.LiveView

  to your LiveView module. See `LiveEvents` for more information on how to emit and handle events.

  The macro imports `LiveEvents.emit/3` and hooks into the LiveView lifecycle to
  add support for the `c:LiveEvents.handle_event/4` callback.
  """

  import LiveEvents.Internal

  defmacro __using__(_) do
    quote do
      @behaviour LiveEvents
      on_mount({LiveEvents.LiveView, __MODULE__})
      import LiveEvents, only: [emit: 2, emit: 3]
    end
  end

  @doc false
  def on_mount(module, _params, _session, socket) do
    {:cont,
     socket
     |> put_module(module)
     |> Phoenix.LiveView.attach_hook(
       :live_events_info,
       :handle_info,
       &handle_info/2
     )}
  end

  defp handle_info(%LiveEvents.Event{} = event, socket) do
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
