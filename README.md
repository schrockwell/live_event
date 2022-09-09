# LiveEvent

![Test Status](https://github.com/schrockwell/live_event/actions/workflows/elixir.yml/badge.svg)
[![Module Version](https://img.shields.io/hexpm/v/live_event.svg)](https://hex.pm/packages/live_event)
[![Hex Docs](https://img.shields.io/badge/hex-docs-purple.svg)](https://hexdocs.pm/live_event/)
[![License](https://img.shields.io/hexpm/l/live_event.svg)](https://github.com/schrockwell/live_event/blob/main/LICENSE)

LiveEvent standardizes the API for emitting and handling events between LiveViews and LiveComponents. Instead of juggling `send/2`, `send_update/2`, `handle_info/2`, and `update/2`, now there is only one API to learn: `emit/3` and `handle_event/4`.

Please see [the docs](https://hexdocs.pm/live_event/) for full documentation and examples.

## Example

```elixir
defmodule MyLiveView do
  use Phoenix.LiveView
  use LiveEvent.LiveView # <-- adds lifecycle hooks

  def render(assigns) do
    ~H"""
    <.live_component module={MyLiveComponent} id="my-component" on_selected={self()} />
    """
  end

  # use handle_event/4 to process events - it works on LiveViews AND LiveComponents
  def handle_event(:on_selected, {MyLiveComponent, "my-component"}, %{at: at}, socket) do
    IO.puts("Selected at #{at}")
    {:ok, socket}
  end
end

defmodule MyLiveComponent do
  use Phoenix.LiveComponent
  use LiveEvent.LiveComponent # <-- adds lifecycle hooks

  def render(assigns) do
    ~H"""
    <button phx-click="click" phx-targt={@myself}>Click me</button>
    """
  end

  def handle_event("click", _, socket) do
    # use emit/3 to send events
    {:noreply, emit(socket, :on_selected, %{at: DateTime.utc_now()})}
  end
end
```

## Installation

The package can be installed
by adding `live_event` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:live_event, "~> 0.1.0"}
  ]
end
```
