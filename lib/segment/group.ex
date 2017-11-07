defmodule Segment.Group do
  @derive [Poison.Encoder]
  @method "group"

  defstruct [
    :userId,
    :groupId,
    :traits,
    :context,
    :timestamp,
    :integrations,
    :anonymousId,
    method: @method
  ]
end
