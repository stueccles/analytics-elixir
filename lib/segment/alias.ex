defmodule Segment.Analytics.Alias do
  alias Segment.Analytics.Http
  @derive [Poison.Encoder]
  @method "alias"

  defstruct [ :userId,
              :previousId,
              :context,
              :timestamp,
              :integrations
            ]

end
