defmodule Segment.Http do
  use HTTPoison.Base

  @base_url "https://api.segment.io/v1/"

  def process_url(url) do
    @base_url <> url
  end

  def process_request_options(options) do
    Keyword.put(options, :basic_auth, {write_key(), ""})
  end

  def process_request_headers(headers) do
    headers
    |> Keyword.put(:"Content-Type", "application/json")
    |> Keyword.put(:accept, "application/json")
  end

  defp write_key() do
    Application.fetch_env!(:segment, :write_key)
  end
end
