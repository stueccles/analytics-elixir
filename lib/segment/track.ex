defmodule Segment.Analytics.Track do
  
  @derive [Poison.Encoder]
  @method "track"

  defstruct [ :userId,
              :event,
              :properties,
              :context,
              :timestamp,
              :integrations,
              :anonymousId
            ]

end
