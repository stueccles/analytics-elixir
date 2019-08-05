defmodule Segment.Analytics.Batcher do
  @moduledoc """

  """
  use GenServer
  alias Segment.Analytics.{Track, Identify, Screen, Alias, Group, Page}

  @max_batch_size Application.get_env(:segment, :max_batch_size, 100)
  @batch_every_ms Application.get_env(:segment, :batch_every_ms, 2000)

  def start_link(api_key) do
    client = Segment.Http.client(api_key)
    GenServer.start_link(__MODULE__, {client, :queue.new()}, name: __MODULE__)
  end

  def start_link(api_key, adapter) do
    client = Segment.Http.client(api_key, adapter)
    GenServer.start_link(__MODULE__, {client, :queue.new()}, name: __MODULE__)
  end

  # client
  def call(%{__struct__: mod} = event)
      when mod in [Track, Identify, Screen, Alias, Group, Page] do
    enqueue(event)
  end

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
  def handle_info(:process_batch, {client, queue}) do
    length = :queue.len(queue)
    {items, queue} = extract_batch(queue, length)

    if length(items) > 0, do: Segment.Http.batch(client, items)

    schedule_batch_send()
    {:noreply, {client, queue}}
  end

  # Helpers
  defp schedule_batch_send do
    Process.send_after(self(), :process_batch, @batch_every_ms)
  end

  defp enqueue(event) do
    GenServer.cast(__MODULE__, {:enqueue, event})
  end

  defp extract_batch(queue, 0),
    do: {[], queue}

  defp extract_batch(queue, length) when length >= @max_batch_size do
    :queue.split(@max_batch_size, queue)
    |> split_result()
  end

  defp extract_batch(queue, length),
    do: :queue.split(length, queue) |> split_result()

  defp split_result({q1, q2}), do: {:queue.to_list(q1), q2}
end
