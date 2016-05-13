defmodule Segment.Analytics.Http do
  use HTTPoison.Base

  @base_url "https://api.segment.io/v1/"

  def process_url(url) do
      @base_url <> url
  end

  def post(url, body, headers, options \\ []) do
    options_with_auth = Keyword.merge(options, [hackney: [basic_auth: {Segment.write_key, ""}]])
    request(:post, url, body, headers, options_with_auth)
  end

  def process_options(options) do
    Dict.put(options, :basic_auth, {Segment.write_key(),""})
  end

  def process_request_headers(headers) do
      Dict.put(headers, :"Content-Type", "application/json")
      |> Dict.put(:"accept", "application/json")
  end
end
