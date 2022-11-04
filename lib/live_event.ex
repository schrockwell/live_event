defmodule LiveEvent do
  import LiveEvent.Internal

  @moduledoc """
  Standardized event handling in LiveViews and LiveComponents.

  ## The problem

  LiveView currently has two built-in mechanisms for sending messages between views and components:

  - `send/2` -> `handle_info/2` for sending to a LiveView
  - `send_update/3` -> `update/2` for sending to a LiveComponent

  Picking a singular approach limits component reusability, and using both approaches results in an inconsistent
  event API.

  ## The solution

  LiveEvent standardizes these systems into a singular flow:

  - `emit/3` -> `c:LiveEvent.handle_emit/4` for sending to a LiveView _or_ LiveComponent

  When `use LiveEvent.LiveComponent` or `use LiveEvent.LiveView` is invoked, it hooks into the lifecycle of the
  view or component to transparently add support for the `c:LiveEvent.handle_emit/4` callback.

  ## Event destinations

  Imagine a LiveComponent that has an `:on_selected` event assign that is raised like so:

      emit(socket, :on_selected)

  To handle the event on a LiveView, pass a pid to the event assign.

  ```heex
  <.live_component module={MyComponent} id="foo" on_selected={self()}>
  ```

  To handle the event on a LiveComponent, pass `{module, id}` to the event assign.

  ```heex
  <.live_component module={MyComponent} id="foo" on_selected={{__MODULE__, @id}}>
  ```

  In both cases, the event is handled by the `c:LiveEvent.handle_emit/4` callback.

      # On a LiveView OR LiveComponent
      def handle_emit(:on_selected, {MyComponent, "foo"}, _payload, socket), do: ...

  # Example

      defmodule MyLiveView do
        use Phoenix.LiveView
        use LiveEvent.LiveView

        def render(assigns) do
          ~H\"\"\"
          <.live_component module={MyLiveComponent} id="my-component" on_selected={self()} />
          \"\"\"
        end

        def handle_emit(:on_selected, {MyLiveComponent, "my-component"}, %{at: at}, socket) do
          IO.puts("Selected at \#{at}")
          {:ok, socket}
        end
      end

      defmodule MyLiveComponent do
        use Phoenix.LiveComponent
        use LiveEvent.LiveComponent

        def render(assigns) do
          ~H\"\"\"
          <button phx-click="click" phx-targt={@myself}>Click me</button>
          \"\"\"
        end

        def handle_emit("click", _, socket) do
          {:noreply, emit(socket, :on_selected, %{at: DateTime.utc_now()})}
        end
      end
  """

  @doc """
  Handle an event message sent by `emit/3` or `send_event/4`.

  Events sent via `emit/3` have a `source` argument of the form `{module, id}`.

  ## Compared to `handle_emit/3`

  This callback is distinct from LiveView's `handle_emit/3` callback in a few important ways:

  - The arity is different
  - The result is `{:ok, socket}`, not `{:noreply, socket}`
  - LiveEvent uses atoms for event names, not strings
  - LiveEvent always originate from the server, not the client

  ## Example

      def handle_emit(:on_profile_selected, {MyLiveComponent, _id}, profile_id, socket), do: ...

  """
  @callback handle_emit(
              name :: atom,
              source :: any,
              payload :: any,
              socket :: LiveView.Socket.t()
            ) ::
              {:ok, socket :: LiveView.Socket.t()}

  @optional_callbacks handle_emit: 4

  @doc """
  Raise an event from a LiveView or LiveComponent.

  The `event_name` argument is the name of the optional socket assign whose value specifies the destination for the event.
  The name of the emitted event defaults to the name of the assign.

  Possible assign values are:

  - `nil` to not raise the event
  - a pid, to send the event to a LiveView
  - `{pid, event_name}` to send the event to a LiveView with a custom event name
  - `{module, id}` to send the event to a LiveComponent
  - `{module, id, event_name}` to send the event to a LiveComponent with a custom event name

  Returns the unmodified socket.
  """
  @spec emit(socket :: Phoenix.LiveView.Socket.t(), event_name :: atom, payload :: any) ::
          Phoenix.LiveView.Socket.t()
  def emit(socket, event_name, payload \\ nil) do
    source = {get_module(socket), socket.assigns[:id]}

    case socket.assigns[event_name] do
      nil ->
        nil

      {pid, custom_name} when is_pid(pid) ->
        send_event(pid, custom_name, payload, source: source)

      {module, id, custom_name} ->
        send_event({module, id}, custom_name, payload, source: source)

      destination ->
        send_event(destination, event_name, payload, source: source)
    end

    socket
  end

  @doc """
  Send an event to a LiveView or LiveComponent.

  Typically, `emit/3` should be used to send events, but this function can be used if more control is needed.

  To send to a LiveView (or any other process), specify a pid (usually `self()`) as the `destination`.
  To send to a LiveComponent, specify `{module, id}` as the `destination`.
  The event can handled by the `c:LiveEvent.handle_emit/4` callback.

  When sending to an arbitrary process, the message will be a `LiveEvent.Event` struct, although you
  should not normally have to deal with that directly.

  ## Options

  - `:source` - where the event originated from; defaults to `nil`

  ## Examples

      send_event(self(), :on_selected, %{profile_id: 123})
      # => def handle_emit(:on_selected, _source, %{profile_id: id}, socket), do: ...

      send_event({MyComponent, "my-id"}, :on_selected, %{profile_id: 123})
      # => def handle_emit(:on_selected, _source, %{profile_id: id}, socket), do: ...
  """
  @spec send_event(
          destination :: LiveView.Event.destination(),
          event_name :: atom,
          payload :: any,
          opts :: keyword
        ) ::
          :ok
  def send_event(destination, event_name, payload, opts \\ []) do
    message = %LiveEvent.Event{name: event_name, source: opts[:source], payload: payload}

    case destination do
      pid when is_pid(pid) ->
        send(pid, message)

      {module, id} when is_atom(module) ->
        Phoenix.LiveView.send_update(module, id: id, __message__: message)
    end

    :ok
  end
end
