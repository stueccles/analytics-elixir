defmodule Segment.Identify do
  @derive [Poison.Encoder]
  @method "identify"

  defstruct [:userId, :traits, :context, :timestamp, :integrations, :anonymousId, method: @method]
end
