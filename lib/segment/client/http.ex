defmodule Segment.Http.Stub do
  require Logger

  def call(env, _opts) do
    Logger.debug("[Segment] HTTP API called with #{inspect(env)}")
    {:ok, %{env | status: 200, body: ""}}
  end
end

defmodule Segment.Http do
  require Logger
  use Retry

  @type client() :: Tesla.Client.t()

  @segment_api_url "https://api.segment.io/v1/"
  @send_to_http Application.get_env(:segment, :send_to_http, true)
  @retry_attempts Application.get_env(:segment, :retry_attempts, 3)
  @retry_expiry Application.get_env(:segment, :retry_expiry, 10_000)
  @retry_start Application.get_env(:segment, :retry_start, 100)

  @spec client(String.t()) :: client()
  def client(api_key) do
    adapter =
      case @send_to_http do
        true ->
          Application.get_env(:segment, :tesla)[:adapter] ||
            {Tesla.Adapter.Hackney, [recv_timeout: 30_000]}

        false ->
          {Segment.Http.Stub, []}
      end

    client(api_key, adapter)
  end

  @spec client(String.t(), any()) :: client()
  def client(api_key, adapter) do
    middleware = [
      {Tesla.Middleware.BaseUrl, @segment_api_url},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.BasicAuth, %{username: api_key, password: ""}}
    ]

    Tesla.client(middleware, adapter)
  end

  def send(client, events) when is_list(events), do: batch(client, events)

  def send(client, event) do
    case make_request(client, event.type, prepare_events(event), @retry_attempts) do
      {:ok, %{status: status}} when status == 200 ->
        :ok

      {:ok, %{status: status}} when status == 400 ->
        Logger.error("[Segment] Call Failed. JSON too large or invalid")
        :error

      {:error, err} ->
        Logger.error("[Segment] Call Failed after #{@retry_attempts} retries. #{inspect(err)}")
        :error

      err ->
        Logger.error("[Segment] Call Failed #{inspect(err)}")
        :error
    end
  end

  def batch(client, events, context \\ nil, integrations \\ nil) do
    data =
      %{batch: prepare_events(events)}
      |> add_if(:context, context)
      |> add_if(:integrations, integrations)

    case make_request(client, "batch", data, @retry_attempts) do
      {:ok, %{status: status}} when status == 200 ->
        :ok

      {:ok, %{status: status}} when status == 400 ->
        Logger.error(
          "[Segment] Batch call of #{length(events)} events failed. JSON too large or invalid"
        )

        :error

      {:error, err} ->
        Logger.error(
          "[Segment] Batch call of #{length(events)} events failed after #{@retry_attempts} retries. #{
            inspect(err)
          }"
        )

        :error

      err ->
        Logger.error("[Segment] Batch callof #{length(events)} events failed #{inspect(err)}")
        :error
    end
  end

  defp make_request(client, url, data, retries) when retries > 0 do
    retry with: linear_backoff(@retry_start, 2) |> cap(@retry_expiry) |> Stream.take(retries) do
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
    |> add_timestamp()
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

  defp add_timestamp(%{timestamp: nil} = map), do: Map.put(map, :timestamp, DateTime.utc_now())
  defp add_timestamp(map), do: map

  defp add_if(map, _key, nil), do: map
  defp add_if(map, key, value), do: Map.put_new(map, key, value)
end
