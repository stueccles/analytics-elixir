defmodule Segment do
  require Logger
  @service Application.get_env(:segment, :sender_impl, Segment.Analytics.Batcher)

  def start_link(api_key) do
    Logger.debug(inspect(@service))
    @service.start_link(api_key)
  end
end
