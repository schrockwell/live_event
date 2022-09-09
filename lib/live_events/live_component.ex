defmodule LiveEvents.LiveComponent do
  @moduledoc """
  Add LiveEvent support to LiveComponents.

  Simply add

      use LiveEvents.LiveComponent

  to your LiveComponent module. See `LiveEvents` for more information on how to emit and handle events.

  The macro imports `LiveEvents.emit/3` and hooks into the LiveComponent update lifecycle to
  add support for the `c:LiveEvents.handle_event/4` callback.
  """

  import LiveEvents.Internal

  defmacro __using__(_) do
    quote do
      @behaviour LiveEvents
      @before_compile LiveEvents.LiveComponent
      import LiveEvents, only: [emit: 2, emit: 3]
    end
  end

  defmacro __before_compile__(env) do
    [
      wrap_mount(env),
      wrap_update(env)
    ]
  end

  # Learned this technique here:
  # https://github.com/surface-ui/surface/blob/a93cfa753cb5bb7155981f4328bb64d01fa5e579/lib/surface/live_view.ex#L77-L104
  defp wrap_mount(env) do
    if Module.defines?(env.module, {:mount, 1}) do
      quote do
        defoverridable mount: 1

        def mount(socket) do
          socket = LiveEvents.LiveComponent.__mount__(socket, __MODULE__)
          super(socket)
        end
      end
    else
      quote do
        def mount(socket) do
          {:ok, LiveEvents.LiveComponent.__mount__(socket, __MODULE__)}
        end
      end
    end
  end

  defp wrap_update(env) do
    if Module.defines?(env.module, {:update, 2}) do
      quote do
        defoverridable update: 2

        def update(assigns, socket) do
          socket = LiveEvents.LiveComponent.__update__(socket, assigns)
          super(assigns, socket)
        end
      end
    else
      quote do
        def update(assigns, socket) do
          {:ok, LiveEvents.LiveComponent.__update__(socket, assigns)}
        end
      end
    end
  end

  def __mount__(socket, module) do
    put_module(socket, module)
  end

  def __update__(socket, %{__message__: %LiveEvents.Event{} = event}) do
    case get_module(socket).handle_event(
           event.name,
           event.source,
           event.payload,
           socket
         ) do
      {:ok, %Phoenix.LiveView.Socket{} = socket} ->
        socket

      _else ->
        raise "expected handle_event/4 callback to return {:ok, %LiveView.Socket{}}"
    end
  end
end
