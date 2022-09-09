defmodule LiveEvents.Event do
  @moduledoc """
  Represents an event message.

  This is documented in the unlikely chance that the destination process or component needs to directly handle it.

  This struct should not be constructed directly by the developer - use `LiveEvents.send_event/4`
  and `LiveEvents.emit/3` instead.
  """

  @type t :: %__MODULE__{
          name: atom,
          payload: any,
          source: any
        }

  @type destination :: pid | {module, String.t() | atom}

  defstruct [:name, :payload, :source]
end
