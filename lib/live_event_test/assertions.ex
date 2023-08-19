defmodule LiveEventTest.Assertions do
  @moduledoc """
  Test assertion helpers for LiveEvent.

  These assertions are designed to work by passing `self()` to the event assign under test, and then asserting that
  the test process received the LiveEvent message.
  """
  import ExUnit.Assertions

  @doc """
  Asserts that an event is or was received by the test process.

  This is a thin wrapper around `ExUnit.Assertions.assert_receive/3`, so look there
  for more docs.

  ## Example

      # On a LiveComponent with the :on_click event assign set to self(), the test
      emit(socket.assigns.on_click, {:click, 123})

      # In the test
      assert_receive_event {:click, 123}

  """
  @spec assert_receive_event(
          payload :: any,
          timeout :: non_neg_integer() | nil,
          failure_message :: String.t() | nil
        ) :: any
  defmacro assert_receive_event(
             payload,
             timeout \\ nil,
             failure_message \\ nil
           ) do
    quote do
      assert_receive %LiveEvent.Event{payload: unquote(payload)}, unquote(timeout), unquote(failure_message)
    end
  end

  @doc """
  Asserts that an event was received by the test process.

  This is a thin wrapper around `ExUnit.Assertions.assert_received/2`, so look there
  for more docs.

  ## Example

      # On a LiveComponent with the :on_click event assign set to self()
      emit(socket.assigns.on_click, {:click, 123})

      # In the test
      assert_received_event {:click, 123}

  """
  @spec assert_received_event(
          payload :: any,
          failure_message :: String.t() | nil
        ) :: any
  defmacro assert_received_event(payload, failure_message \\ nil) do
    quote do
      assert_received %LiveEvent.Event{payload: unquote(payload)}, unquote(failure_message)
    end
  end

  @doc """
  Asserts that an event isn't or wasn't received by the test process.

  This is a thin wrapper around `ExUnit.Assertions.refute_receive/3`, so look there
  for more docs.

  ## Example

      # On a LiveComponent with the :on_click event assign set to self()
      emit(socket.assigns.on_click, {:clicked, 123})

      # In the test
      refute_receive_event {:click, 456}

  """
  @spec refute_receive_event(
          payload :: any,
          timeout :: non_neg_integer() | nil,
          failure_message :: String.t() | nil
        ) :: any
  defmacro refute_receive_event(
             payload,
             timeout \\ nil,
             failure_message \\ nil
           ) do
    quote do
      refute_receive %LiveEvent.Event{payload: unquote(payload)},
                     unquote(timeout),
                     unquote(failure_message)
    end
  end

  @doc """
  Asserts that an event wasn't received by the test process.

  This is a thin wrapper around `ExUnit.Assertions.refute_received/2`, so look there
  for more docs.

  ## Example

      # On a LiveComponent with the :on_click event assign set to self()
      emit(socket.assigns.on_click, {:clicked, 123})

      # In the test
      refute_received_event {:clicked, 456}

  """
  @spec refute_received_event(
          payload :: any,
          failure_message :: String.t() | nil
        ) :: any
  defmacro refute_received_event(payload, failure_message \\ nil) do
    quote do
      refute_received %LiveEvent.Event{payload: unquote(payload)},
                      unquote(failure_message)
    end
  end
end
