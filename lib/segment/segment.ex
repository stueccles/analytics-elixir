defmodule Segment do
  @service Application.get_env(:segment, :sender_impl, Segment.Analytics.Batcher)

  def start_link(api_key) do
    @service.start_link(api_key)
  end
end
