defmodule Segment.Analytics.Http do
  use HTTPotion.Base

  @base_url "https://api.segment.io/v1/"

  def process_url(url) do
      @base_url <> url
  end

  def process_options(options) do
    Dict.put(options, :basic_auth, {Segment.write_key(),""})
  end

  def process_request_headers(headers) do
      Dict.put(headers, :"Content-Type", "application/json")
      |> Dict.put(:"accept", "application/json")
  end
end
