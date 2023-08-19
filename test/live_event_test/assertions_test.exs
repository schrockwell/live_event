defmodule LiveEventTest.AssertionsTest do
  use ExUnit.Case

  import LiveEventTest.Assertions

  describe "assert_receive_event/3" do
    test "works" do
      LiveEvent.emit(self(), :payload)
      assert_receive_event(:payload)
    end
  end

  describe "assert_received_event/3" do
    test "works" do
      LiveEvent.emit(self(), :payload)
      assert_received_event(:payload)
    end
  end

  describe "refute_receive_event/3" do
    test "works" do
      refute_receive_event _
    end
  end

  describe "refute_received_event/3" do
    test "works" do
      refute_received_event _
    end
  end
end
