defmodule LiveEventTest do
  use ExUnit.Case

  import LiveEventTest.TestModules
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  alias LiveEvent

  @endpoint LiveEventTest.Endpoint

  setup do
    start_supervised!(@endpoint)
    :ok
  end

  defcomponent ButtonComponent do
    def handle_event("event", params, socket) do
      {:noreply, emit(socket, :event, params)}
    end

    def render(assigns) do
      ~H[<button id={@id} phx-click="event" phx-target={@myself}>Click me</button>]
    end
  end

  defcomponent InspectComponent do
    def mount(socket) do
      {:ok, assign(socket, :payload, nil)}
    end

    def handle_event(:event, _source, payload, socket) do
      {:ok, assign(socket, :payload, payload)}
    end

    def render(assigns) do
      ~H[<div id={@id}><%= inspect(@payload) %></div>]
    end
  end

  defview TestLive do
    def mount(_, _, socket) do
      {:ok, assign(socket, :payload, nil)}
    end

    def render(assigns) do
      ~H"""
      <div>
        <.live_component module={ButtonComponent} id="button-to-view" event={self()} />
        <.live_component module={ButtonComponent} id="button-to-component" event={{InspectComponent, "inspect-in-component"}} />

        <.live_component module={InspectComponent} id="inspect-in-component" />
        <div id="inspect-in-view"><%= inspect(@payload) %></div>
      </div>
      """
    end

    def handle_event(:event, {ButtonComponent, "button-to-view"}, payload, socket) do
      {:ok, assign(socket, :payload, payload)}
    end
  end

  describe "emitting an event from a LiveComponent to a LiveView" do
    test "works" do
      # GIVEN
      payload = %{"foo" => "bar"}
      {:ok, view, _html} = live_isolated(build_conn(), TestLive)
      refute has_element?(view, "#inspect-in-view", inspect(payload))

      # WHEN
      view |> element("#button-to-view") |> render_click(payload)

      # THEN
      assert has_element?(view, "#inspect-in-view", inspect(payload))
    end
  end

  describe "emitting an event from a LiveComponent to a LiveComponent" do
    test "works" do
      # GIVEN
      payload = %{"foo" => "bar"}
      {:ok, view, _html} = live_isolated(build_conn(), TestLive)
      refute has_element?(view, "#inspect-in-component", inspect(payload))

      # WHEN
      view |> element("#button-to-component") |> render_click(payload)

      # THEN
      assert has_element?(view, "#inspect-in-component", inspect(payload))
    end
  end
end
