defmodule Segment.Analytics.Http do
  use HTTPoison.Base

  def process_url(url) do
    Segment.endpoint() <> url
  end

  def process_request_headers(headers) do
    headers
    |> Keyword.put(:"Content-Type", "application/json")
    |> Keyword.put(:accept, "application/json")
    |> Keyword.put(:"x-api-key", Segment.key())
  end
end
