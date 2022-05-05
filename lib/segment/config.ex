defmodule Segment.Config do
  @moduledoc false

  def api_url do
    Application.get_env(:segment, :api_url, "https://api.segment.io/v1/")
  end

  def service do
    Application.get_env(:segment, :sender_impl, Segment.Analytics.Batcher)
  end

  def max_batch_size() do
    Application.get_env(:segment, :max_batch_size, 100)
  end

  def batch_every_ms() do
    Application.get_env(:segment, :batch_every_ms, 2000)
  end

  def send_to_http() do
    Application.get_env(:segment, :send_to_http, true)
  end

  def retry_attempts() do
    Application.get_env(:segment, :retry_attempts, 3)
  end

  def retry_expiry() do
    Application.get_env(:segment, :retry_expiry, 10_000)
  end

  def retry_start() do
    Application.get_env(:segment, :retry_start, 100)
  end
end
