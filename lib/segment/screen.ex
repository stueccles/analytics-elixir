defmodule Segment.Screen do
  @derive [Poison.Encoder]
  @method "screen"

  defstruct [
    :userId,
    :name,
    :properties,
    :context,
    :timestamp,
    :integrations,
    :anonymousId,
    method: @method
  ]
end
