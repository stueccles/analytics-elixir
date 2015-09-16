defmodule Segment.Analytics.Identify do
  @derive [Poison.Encoder]
  @method "identify"

  defstruct [ :userId,
              :traits,
              :context,
              :timestamp,
              :integrations,
              :anonymousId
            ]

end
