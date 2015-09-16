defmodule Segment.Analytics.Page do
  @derive [Poison.Encoder]
  @method "page"

  defstruct [ :userId,
              :name,
              :properties,
              :context,
              :timestamp,
              :integrations,
              :anonymousId]

end
