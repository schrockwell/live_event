defmodule LiveEvent.Event do
  @moduledoc """
  Represents an event message.

  This is documented in the unlikely chance that the destination process or component needs to directly handle it.

  This struct should not be constructed directly by the developer - use `LiveEvent.emit/2` instead.
  """

  @type t :: %__MODULE__{
          payload: any
        }

  defstruct [:payload]
end
