defmodule LiveEventTest.AssertionsTest do
  use ExUnit.Case

  import LiveEventTest.Assertions

  describe "assert_receive_event/3" do
    test "works" do
      LiveEvent.send_event(self(), :event, :payload, source: :source)
      assert_receive_event :event, :source, :payload

      LiveEvent.send_event(self(), :event, :payload, source: :source)
      assert_receive_event :event, _, :payload

      LiveEvent.send_event(self(), :event, :payload, source: :source)
      assert_receive_event _, _, _
    end
  end

  describe "assert_received_event/3" do
    test "works" do
      LiveEvent.send_event(self(), :event, :payload, source: :source)
      assert_received_event :event, :source, :payload

      LiveEvent.send_event(self(), :event, :payload, source: :source)
      assert_received_event :event, _, :payload

      LiveEvent.send_event(self(), :event, :payload, source: :source)
      assert_received_event _, _, _
    end
  end

  describe "refute_receive_event/3" do
    test "works" do
      refute_receive_event _, _, _
    end
  end

  describe "refute_received_event/3" do
    test "works" do
      refute_received_event _, _, _
    end
  end
end
