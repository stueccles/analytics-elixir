defmodule Segment.Analytics.Group do
  @derive [Poison.Encoder]
  @method "group"

  defstruct [ :userId,
              :groupId,
              :traits,
              :context,
              :timestamp,
              :integrations,
              :anonymousId
            ]
end
