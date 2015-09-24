defmodule Segment.Analytics.Alias do
  @derive [Poison.Encoder]
  @method "alias"

  defstruct [ :userId,
              :previousId,
              :context,
              :timestamp,
              :integrations
            ]

end
