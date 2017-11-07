defmodule Segment.Alias do
  @derive [Poison.Encoder]
  @method "alias"

  defstruct [:userId, :previousId, :context, :timestamp, :integrations, method: @method]
end
