defmodule Segment.Analytics.Http do
  use HTTPoison.Base

  @base_url "https://api.segment.io/v1/"

  def process_url(url) do
    @base_url <> url
  end

  def post(url, body, headers, options \\ []) do
    augmented_options =
      options
      |> Keyword.merge([hackney: [basic_auth: {Segment.write_key(), ""}]])
      |> maybe_add_sni(url)

    request(:post, url, body, headers, augmented_options)
  end

  def process_options(options) do
    Keyword.put(options, :basic_auth, {Segment.write_key(),""})
  end

  def process_request_headers(headers) do
    headers
    |> Keyword.put(:"Content-Type", "application/json")
    |> Keyword.put(:"accept", "application/json")
  end

  # Adds Server Name Indication SSL option to HTTPoison options, if applicable.
  # This shouldn't be necessary, but addresses an issue with TLS handshake failures.
  defp maybe_add_sni(options, url) do
    host = URI.parse(url).host
    ssl_options = Keyword.get(options, :ssl)

    # http_util.is_hostname expects a charlist, not a String/binary
    if host && String.to_charlist(host) |> :http_util.is_hostname() do
      # Prefer caller-supplied value for server_name_indication option.
      ssl_options_with_sni = Keyword.merge([server_name_indication: host], ssl_options || [])
      Keyword.merge(options, [ssl: ssl_options_with_sni])
    else
      options
    end
  end
end
