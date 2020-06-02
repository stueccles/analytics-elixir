defmodule Segment.Analytics.Batcher do
  @moduledoc """
    The `Segment.Analytics.Batcher` module is the default service implementation for the library which uses the
    [Segment Batch HTTP API](https://segment.com/docs/sources/server/http/#batch) to put events in a FIFO queue and
    send on a regular basis.

    The `Segment.Analytics.Batcher` can be configured with
    ```elixir
    config :segment,
      max_batch_size: 100,
      batch_every_ms: 5000
    ```
    * `config :segment, :max_batch_size` The maximum batch size of messages that will be sent to Segment at one time. Default value is 100.
    * `config :segment, :batch_every_ms` The time (in ms) between every batch request. Default value is 2000 (2 seconds)

    The Segment Batch API does have limits on the batch size "There is a maximum of 500KB per batch request and 32KB per call.". While
    the library doesn't check the size of the batch, if this becomes a problem you can change `max_batch_size` to a lower number and probably want
    to change `batch_every_ms` to run more frequently. The Segment API asks you to limit calls to under 50 a second, so even if you have no other
    Segment calls going on, don't go under 20ms!

  """
  use GenServer
  alias Segment.Analytics.{Track, Identify, Screen, Alias, Group, Page}

  @doc """
    Start the `Segment.Analytics.Batcher` GenServer with an Segment HTTP Source API Write Key
  """
  @spec start_link(String.t()) :: GenServer.on_start()
  def start_link(api_key) do
    client = Segment.Http.client(api_key)
    GenServer.start_link(__MODULE__, {client, :queue.new()}, name: String.to_atom(api_key))
  end

  @doc """
    Start the `Segment.Analytics.Batcher` GenServer with an Segment HTTP Source API Write Key and a Tesla Adapter. This is mainly used
    for testing purposes to override the Adapter with a Mock.
  """
  @spec start_link(String.t(), Tesla.adapter()) :: GenServer.on_start()
  def start_link(api_key, adapter) do
    client = Segment.Http.client(api_key, adapter)
    GenServer.start_link(__MODULE__, {client, :queue.new()}, name: __MODULE__)
  end

  # client
  @doc """
    Make a call to Segment with an event. Should be of type `Track, Identify, Screen, Alias, Group or Page`.
    This event will be queued and sent later in a batch.
  """
  @spec call(Segment.segment_event(), pid() | __MODULE__.t()) :: :ok
  def call(%{__struct__: mod} = event, pid \\ __MODULE__)
      when mod in [Track, Identify, Screen, Alias, Group, Page] do
    enqueue(event, pid)
  end

  @doc """
    Force the batcher to flush the queue and send all the events as a big batch (warning could exceed batch size)
  """
  @spec flush(pid() | __MODULE__.t()) :: :ok
  def flush(pid \\ __MODULE__), do: GenServer.call(pid, :flush)

  # GenServer Callbacks

  @impl true
  def init({client, queue}) do
    schedule_batch_send()
    {:ok, {client, queue}}
  end

  @impl true
  def handle_cast({:enqueue, event}, {client, queue}) do
    {:noreply, {client, :queue.in(event, queue)}}
  end

  @impl true
  def handle_call(:flush, _from, {client, queue}) do
    items = :queue.to_list(queue)
    if length(items) > 0, do: Segment.Http.batch(client, items)
    {:reply, :ok, {client, :queue.new()}}
  end

  @impl true
  def handle_info(:process_batch, {client, queue}) do
    length = :queue.len(queue)
    {items, queue} = extract_batch(queue, length)

    if length(items) > 0, do: Segment.Http.batch(client, items)

    schedule_batch_send()
    {:noreply, {client, queue}}
  end

  # Helpers
  defp schedule_batch_send do
    Process.send_after(self(), :process_batch, Segment.Config.batch_every_ms())
  end

  defp enqueue(event, pid), do: GenServer.cast(pid, {:enqueue, event})

  defp extract_batch(queue, 0),
    do: {[], queue}

  defp extract_batch(queue, length) do
    max_batch_size = Segment.Config.max_batch_size()

    if length >= max_batch_size do
      :queue.split(max_batch_size, queue)
      |> split_result()
    else
      :queue.split(length, queue) |> split_result()
    end
  end

  defp split_result({q1, q2}), do: {:queue.to_list(q1), q2}
end
