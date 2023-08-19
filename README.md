# LiveEvent

![Test Status](https://github.com/schrockwell/live_event/actions/workflows/elixir.yml/badge.svg)
[![Module Version](https://img.shields.io/hexpm/v/live_event.svg)](https://hex.pm/packages/live_event)
[![Hex Docs](https://img.shields.io/badge/hex-docs-purple.svg)](https://hexdocs.pm/live_event/)
[![License](https://img.shields.io/hexpm/l/live_event.svg)](https://github.com/schrockwell/live_event/blob/main/LICENSE)

LiveEvent adds a simple API to LiveViews and LiveComponents:

- `emit/2` to raise an event
- `handle_emit/2` to handle it

LiveView 0.18+ is supported.

With these two functions, server-side event messages can be handled the same way by both LiveViews and LiveComponents, facilitating the easier design of flexible, reusable components.

Please see [the docs](https://hexdocs.pm/live_event/) for full documentation and examples.

**NOTE: There are breaking API changes introduced in v0.4.0. But don't worry, it's for the better.**

## Example

Let's define a fancy button component that emits a click event with a timestamp.

```elixir
defmodule FancyButton do
  use Phoenix.LiveComponent
  use LiveEvent.LiveComponent # <-- new!

  def handle_event("click", _, socket) do
    emit(socket.assigns.on_click, {:click, DateTime.utc_now()})
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <button phx-click="click" phx-target={@myself}>Click me</button>
    """
  end
end
```

And a LiveView that handles that event.

```elixir
defmodule FancyView do
  use Phoenix.LiveView
  use LiveEvent.LiveView # <-- new!

  def handle_emit({:click, timestamp}, socket) do
    # ...do something with the event...
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={FancyButton} id="fancy-button" on_click={self()} />
    """
  end
end
```

Using the exact same syntax, you can also have a LiveComponent handle the same event from the FancyButton.

```elixir
defmodule ContainerComponent do
  use Phoenix.LiveComponent
  use LiveEvent.LiveComponent # <-- new!

  def handle_emit({:click, timestamp}, socket) do
    # ...do something with the event...
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={FancyButton} id="fancy-button" on_click={{__MODULE__, @id}}} />
    """
  end
end
```

## Installation

Add the dependency to `mix.exs`:

```elixir
def deps do
  {:live_event, "~> 0.4.0"}
end
```

Update `MyAppWeb` to include the integrations:

```elixir
def MyAppWeb do
  def live_view do
    use LiveEvent.LiveView
  end

  def live_component do
    use LiveEvent.LiveComponent
  end
end
```
