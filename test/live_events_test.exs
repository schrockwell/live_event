defmodule LiveEventsTest do
  use ExUnit.Case
  doctest LiveEvents

  test "greets the world" do
    assert LiveEvents.hello() == :world
  end
end
