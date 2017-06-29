defmodule Segment.Analytics.Http do
  use HTTPoison.Base

  @base_url "https://api.segment.io/v1/"

  def process_url(url) do
    @base_url <> url
  end

  def post(url, body, headers, options \\ []) do
    options_with_auth =
      Keyword.merge(options, [hackney: [basic_auth: {Segment.write_key(), ""}]])

    request(:post, url, body, headers, options_with_auth)
  end

  def process_options(options) do
    Keyword.put(options, :basic_auth, {Segment.write_key(),""})
  end

  def process_request_headers(headers) do
    headers
    |> Keyword.put(:"Content-Type", "application/json")
    |> Keyword.put(:"accept", "application/json")
  end
end
