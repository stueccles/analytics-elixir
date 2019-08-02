defmodule Segment do
  require Logger
  @service Application.get_env(:segment, :sender_impl, Segment.Analytics.Batcher)

  def start_link(api_key) do
    @service.start_link(api_key)
  end

  def start_link(api_key, adapter) do
    @service.start_link(api_key, adapter)
  end
end
