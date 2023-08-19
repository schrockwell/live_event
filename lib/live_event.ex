defmodule LiveEvent do
  @moduledoc """
  Standardized event handling in LiveViews and LiveComponents.

  Out of the box, LiveView has two distinct mechanisms for sending messages to LiveViews and LiveComponents:

  - `send/2` to send to a LiveView
    - `c:Phoenix.LiveView.handle_info/2` to receive in a LiveView
  - `Phoenix.LiveView.send_update/3` to send to a LiveComponent
    - `c:Phoenix.LiveComponent.update/2` to receive in a LiveComponent

  LiveEvent standardizes this API with a single pair of functions that work both sending and receiving
  in both LiveView and LiveComponents:

  - `emit/2` to send to a LiveView or LiveComponent
    - `c:handle_emit/2` to receive in a LiveView or LiveComponent

  ## Example

  Let's define a fancy button component that emits a click event with a timestamp.

      defmodule FancyButton do
        use Phoenix.LiveComponent
        use LiveEvent.LiveComponent # <-- new!

        def handle_event("click", _, socket) do
          emit(socket.assigns.on_click, {:click, DateTime.utc_now()})
          {:noreply, socket}
        end

        def render(assigns) do
          ~H"\"\"
          <button phx-click="click" phx-target={@myself}>Click me</button>
          \"\"\"
        end
      end

  And a LiveView that handles that event.

      defmodule FancyView do
        use Phoenix.LiveView
        use LiveEvent.LiveView # <-- new!

        def handle_emit({:click, timestamp}, socket) do
          # ...do something with the event...
          {:ok, socket}
        end

        def render(assigns) do
          ~H\"\"\"
          <.live_component module={FancyButton} id="fancy-button" on_click={self()} />
          \"\"\"
        end
      end

  Using the exact same syntax, you can also have a LiveComponent handle the same event from the FancyButton.

      defmodule ContainerComponent do
        use Phoenix.LiveComponent
        use LiveEvent.LiveComponent # <-- new!

        def handle_emit({:click, timestamp}, socket) do
          # ...do something with the event...
          {:ok, socket}
        end

        def render(assigns) do
          ~H\"\"\"
          <.live_component module={FancyButton} id="fancy-button" on_click={{__MODULE__, @id}}} />
          \"\"\"
        end
      end

  ## Installation

  Add the dependency to `mix.exs`:

      def deps do
        {:live_event, "~> #{LiveEvent.MixProject.project()[:version]}"}
      end

  Update `MyAppWeb` to include the integrations:

      def MyAppWeb do
        def live_view do
          use LiveEvent.LiveView
        end

        def live_component do
          use LiveEvent.LiveComponent
        end
      end
  """

  @doc """
  Handle an event message sent by `emit/2`.

  For this callback to work, `use LiveEvent.LiveView` or `use LiveEvent.LiveComponent` must be called
  in the module.

  ## Example

      def handle_emit({:profile_selected, profile_id}, socket), do: ...

  """


  @callback handle_emit(payload :: any, socket :: LiveView.Socket.t()) :: {:ok, socket :: LiveView.Socket.t()}

  @optional_callbacks handle_emit: 2

  @doc """
  Send an event to either a LiveView or LiveComponent.

  To send to a LiveView, specify a pid as the `target`.

  To send to a LiveComponent, specify a `{module, id}` as the `target`.

  In either case, the event can handled by the `c:LiveEvent.handle_emit/2` callback.

  ## Example

      emit(socket.assigns.on_profile_selected, {:profile_selected, socket.assigns.profile_id})
  """
  @spec emit(target :: pid | {module, String.t() | atom}, payload :: any) :: :ok
  def emit(target, payload) do
    message = %LiveEvent.Event{payload: payload}

    case target do
      pid when is_pid(pid) -> send(pid, message)
      {module, id} when is_atom(module) -> Phoenix.LiveView.send_update(module, id: id, __message__: message)
    end

    :ok
  end
end
