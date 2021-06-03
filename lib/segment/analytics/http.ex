defmodule Segment.Analytics.Http do
  def post(path, body, options) do
    path
    |> process_url(options)
    |> HTTPoison.post(body, process_request_headers(options))
  end

  def process_url(path, options),
    do: get_config(options, :endpoint, &Segment.endpoint/0) <> path

  def process_request_headers(options) do
    [
      {"Content-Type", "application/json"},
      {"Accept", "application/json"},
      {"x-api-key", get_config(options, :key, &Segment.key/0)}
    ]
  end

  def get_config(options, key, default_func),
    do: Keyword.get(options, key) || default_func.()
end
