defmodule Segment.Http.Stub do
  @moduledoc """
  The `Segment.Http.Stub` is used to replace the Tesla adapter with something that logs and returns success. It is used if `send_to_http` has been set to false
  """
  require Logger

  def call(env, _opts) do
    Logger.debug("[Segment] HTTP API called with #{inspect(env)}")
    {:ok, %{env | status: 200, body: ""}}
  end
end

defmodule Segment.Http do
  @moduledoc """
  `Segment.Http` is the underlying implementation for making calls to the Segment HTTP API.

  The `send/2` and `batch/4` methods can be used for sending events or batches of events to the API.  The sending can be configured with
  ```elixir
  config :segment,
  send_to_http: true
  retry_attempts: 3,
  retry_expiry: 10_000,
  retry_start: 100
  ```
  * `config :segment, :retry_attempts` The number of times to retry sending against the segment API. Default value is 3
  * `config :segment, :retry_expiry` The maximum time (in ms) spent retrying. Default value is 10000 (10 seconds)
  * `config :segment, :retry_start` The time (in ms) to start the first retry. Default value is 100
  * `config :segment, :send_to_http` If set to `false`, the libray will override the Tesla Adapter implementation to only log segment calls to `debug` but not make any actual API calls. This can be useful if you want to switch off Segment for test or dev. Default value is true

  The retry uses a linear back-off strategy when retring the Segment API.

  Additionally a different Tesla Adapter can be used if you want to use something other than Hackney.

  * `config :segment, :tesla, :adapter` This config option allows for overriding the HTTP Adapter for Tesla (which the library defaults to Hackney).This can be useful if you prefer something else, or want to mock the adapter for testing.

  """
  @type client :: Tesla.Client.t()
  @type adapter :: Tesla.adapter()

  require Logger
  use Retry

  @segment_api_url "https://api.segment.io/v1/"

  @doc """
    Create a Tesla client with the Segment Source Write API Key
  """
  @spec client(String.t()) :: client()
  def client(api_key) do
    adapter =
      case Segment.Config.send_to_http() do
        true ->
          Application.get_env(:segment, :tesla)[:adapter] ||
            {Tesla.Adapter.Hackney, [recv_timeout: 30_000]}

        false ->
          {Segment.Http.Stub, []}
      end

    client(api_key, adapter)
  end

  @doc """
    Create a Tesla client with the Segment Source Write API Key and the given Tesla adapter
  """
  @spec client(String.t(), adapter()) :: client()
  def client(api_key, adapter) do
    middleware = [
      {Tesla.Middleware.BaseUrl, @segment_api_url},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.BasicAuth, %{username: api_key, password: ""}}
    ]

    Tesla.client(middleware, adapter)
  end

  @doc """
    Send a list of Segment events as a batch
  """
  @spec send(String.t(), list(Segment.segment_event())) :: :ok | :error
  def send(client, events) when is_list(events), do: batch(client, events)

  @doc """
    Send a list of Segment events as a batch
  """
  @spec send(String.t(), Segment.segment_event()) :: :ok | :error
  def send(client, event) do
    case make_request(client, event.type, prepare_events(event), Segment.Config.retry_attempts()) do
      {:ok, %{status: status}} when status == 200 ->
        :ok

      {:ok, %{status: status}} when status == 400 ->
        Logger.error("[Segment] Call Failed. JSON too large or invalid")
        :error

      {:error, err} ->
        Logger.error(
          "[Segment] Call Failed after #{Segment.Config.retry_attempts()} retries. #{inspect(err)}"
        )

        :error

      err ->
        Logger.error("[Segment] Call Failed #{inspect(err)}")
        :error
    end
  end

  @doc """
    Send a list of Segment events as a batch.

    The `batch` function takes optional arguments for context and integrations which can
    be applied to the entire batch of events. See [Segment's docs](https://segment.com/docs/sources/server/http/#batch)
  """
  @spec batch(String.t(), list(Segment.segment_event()), map() | nil, map() | nil) :: :ok | :error
  def batch(client, events, context \\ nil, integrations \\ nil) do
    data =
      %{batch: prepare_events(events)}
      |> add_if(:context, context)
      |> add_if(:integrations, integrations)

    case make_request(client, "batch", data, Segment.Config.retry_attempts()) do
      {:ok, %{status: status}} when status == 200 ->
        :ok

      {:ok, %{status: status}} when status == 400 ->
        Logger.error(
          "[Segment] Batch call of #{length(events)} events failed. JSON too large or invalid"
        )

        :error

      {:error, err} ->
        Logger.error(
          "[Segment] Batch call of #{length(events)} events failed after #{
            Segment.Config.retry_attempts()
          } retries. #{inspect(err)}"
        )

        :error

      err ->
        Logger.error("[Segment] Batch callof #{length(events)} events failed #{inspect(err)}")
        :error
    end
  end

  defp make_request(client, url, data, retries) when retries > 0 do
    retry with:
            linear_backoff(Segment.Config.retry_start(), 2)
            |> cap(Segment.Config.retry_expiry())
            |> Stream.take(retries) do
      Tesla.post(client, url, data)
    after
      result -> result
    else
      error -> error
    end
  end

  defp make_request(client, url, data, _retries) do
    Tesla.post(client, url, data)
  end

  defp prepare_events(items) when is_list(items), do: Enum.map(items, &prepare_events/1)

  defp prepare_events(item) do
    Map.from_struct(item)
    |> prep_context()
    |> add_sent_at()
    |> drop_nils()
  end

  defp drop_nils(map) do
    map
    |> Enum.filter(fn
      {_, %{} = item} when map_size(item) == 0 -> false
      {_, nil} -> false
      {_, _} -> true
    end)
    |> Enum.into(%{})
  end

  defp prep_context(%{context: nil} = map),
    do: %{map | context: map_content(Segment.Analytics.Context.new())}

  defp prep_context(%{context: context} = map), do: %{map | context: map_content(context)}

  defp prep_context(map),
    do: Map.put_new(map, :context, map_content(Segment.Analytics.Context.new()))

  defp map_content(%Segment.Analytics.Context{} = context), do: Map.from_struct(context)
  defp map_content(context) when is_map(context), do: context

  defp add_sent_at(%{sentAt: nil} = map), do: Map.put(map, :sentAt, DateTime.utc_now())
  defp add_sent_at(map), do: Map.put_new(map, :sentAt, DateTime.utc_now())

  defp add_if(map, _key, nil), do: map
  defp add_if(map, key, value), do: Map.put_new(map, key, value)
end
