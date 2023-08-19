defmodule LiveEvent.LiveComponent do
  @moduledoc """
  Add LiveEvent support to LiveComponents.

  Simply add

      use LiveEvent.LiveComponent

  to your LiveComponent module. See `LiveEvent` for more information on how to emit and handle events.

  The macro imports `LiveEvent.emit/2` and hooks into the LiveComponent update lifecycle to
  add support for the `c:LiveEvent.handle_emit/2` callback.
  """

  defmacro __using__(_) do
    quote do
      @behaviour LiveEvent
      @before_compile LiveEvent.LiveComponent
      import LiveEvent, only: [emit: 2]
    end
  end

  defmacro __before_compile__(env) do
    [wrap_update(env)]
  end

  # Learned this technique here:
  # https://github.com/surface-ui/surface/blob/a93cfa753cb5bb7155981f4328bb64d01fa5e579/lib/surface/live_view.ex#L77-L104
  defp wrap_update(env) do
    if Module.defines?(env.module, {:update, 2}) do
      quote do
        defoverridable update: 2

        def update(%{__message__: %LiveEvent.Event{} = event} = assigns, socket) do
          {:ok, LiveEvent.LiveComponent.__handle_emit__(__MODULE__, socket, event)}
        end

        def update(assigns, socket) do
          super(assigns, socket)
        end
      end
    else
      quote do
        def update(%{__message__: %LiveEvent.Event{} = event} = assigns, socket) do
          {:ok, LiveEvent.LiveComponent.__handle_emit__(__MODULE__, socket, event)}
        end

        def update(assigns, socket) do
          {:ok, Phoenix.Component.assign(socket, assigns)}
        end
      end
    end
  end

  def __handle_emit__(module, socket, %LiveEvent.Event{} = event) do
    case module.handle_emit(event.payload, socket) do
      {:ok, %Phoenix.LiveView.Socket{} = socket} ->
        socket

      _else ->
        raise "expected handle_emit/2 callback to return {:ok, %LiveView.Socket{}}"
    end
  end
end
