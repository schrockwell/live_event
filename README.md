# LiveEvent

![Test Status](https://github.com/schrockwell/live_event/actions/workflows/elixir.yml/badge.svg)
[![Module Version](https://img.shields.io/hexpm/v/live_event.svg)](https://hex.pm/packages/live_event)
[![Hex Docs](https://img.shields.io/badge/hex-docs-purple.svg)](https://hexdocs.pm/live_event/)
[![License](https://img.shields.io/hexpm/l/live_event.svg)](https://github.com/schrockwell/live_event/blob/main/LICENSE)

LiveEvent adds a simple API to LiveViews and LiveComponents:

- `emit/3` to raise an event
- `handle_emit/4` to handle it

With these two functions, server-side event messages can be handled the same way by both LiveViews and LiveComponents, facilitating the easier design of flexible, reusable components.

Please see [the docs](https://hexdocs.pm/live_event/) for full documentation and examples.

## Usage

Imagine a LiveComponent that has an `:on_selected` event.

```elixir
# Raise an event from a LiveComponent
emit(socket, :on_selected, %{id: 123})

# Handle the event on a LiveView, OR another LiveComponent
def handle_emit(:on_selected, {MyComponent, "component-id"}, %{id: id}, socket), do: ...
```

To send component events to a LiveView, pass `self()` to the `:on_selected` assign.

To send component events to a LiveComponent, pass `{module, id}` to the `:on_selected` assign.

That's all there is to it.

## Example

```elixir
defmodule MyLiveComponent do
  use Phoenix.LiveComponent
  use LiveEvent.LiveComponent # <-- adds lifecycle hooks and imports

  def render(assigns) do
    ~H"""
    <button phx-click="click" phx-target={@myself}>Click me</button>
    """
  end

  def handle_event("click", _, socket) do
    # use emit/3 to send events
    {:noreply, emit(socket, :on_selected, %{at: DateTime.utc_now()})}
  end
end

defmodule MyLiveView do
  use Phoenix.LiveView
  use LiveEvent.LiveView # <-- adds lifecycle hooks and imports

  def render(assigns) do
    ~H"""
    <.live_component module={MyLiveComponent} id="my-component" on_selected={self()} />
    """
  end

  # use handle_emit/4 to process events - it works on LiveViews AND LiveComponents
  def handle_emit(:on_selected, {MyLiveComponent, "my-component"}, %{at: at}, socket) do
    IO.puts("Selected at #{at}")
    {:ok, socket}
  end
end
```

## Installation

The package can be installed
by adding `live_event` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:live_event, "~> 0.2.0"}
  ]
end
```

For Phoenix projects, add the LiveEvent hooks to the `live_view` and `live_component` macros.

```elixir
# lib/my_app_web.ex
defmodule MyAppWeb do
  def live_view do
    quote do
      use LiveEvent.LiveView
    end
  end

  def live_component do
    quote do
      use LiveEvent.LiveComponent
    end
  end
end
```
