defmodule Segment.Page do
  @derive [Poison.Encoder]
  @method "page"

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
