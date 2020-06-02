defmodule Segment.Analytics.Sender do
  @moduledoc """
    The `Segment.Analytics.Sender` service implementation is an alternative to the default Batcher to send every event as it is called.
    The HTTP call is made with an async `Task` to not block the GenServer. This will not guarantee ordering.

    The `Segment.Analytics.Batcher` should be preferred in production but this module will emulate the implementaiton of the original library if
    you need that or need events to be as real-time as possible.
  """
  use GenServer
  alias Segment.Analytics.{Track, Identify, Screen, Alias, Group, Page}

  @doc """
    Start the `Segment.Analytics.Sender` GenServer with an Segment HTTP Source API Write Key
  """
  @spec start_link(String.t()) :: GenServer.on_start()
  def start_link(api_key) do
    client = Segment.Http.client(api_key)
    GenServer.start_link(__MODULE__, client, name: String.to_atom(api_key))
  end

  @doc """
    Start the `Segment.Analytics.Sender` GenServer with an Segment HTTP Source API Write Key and a Tesla Adapter. This is mainly used
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
    This event will be sent immediately and asyncronously
  """
  @spec call(Segment.segment_event(), pid() | __MODULE__.t()) :: :ok
  def call(%{__struct__: mod} = event, pid \\ __MODULE__)
      when mod in [Track, Identify, Screen, Alias, Group, Page] do
    callp(event, pid)
  end

  # GenServer Callbacks

  @impl true
  def init(client) do
    {:ok, client}
  end

  @impl true
  def handle_cast({:send, event}, client) do
    Task.start_link(fn -> Segment.Http.send(client, event) end)
    {:noreply, client}
  end

  # Helpers
  defp callp(event, pid), do: GenServer.cast(pid, {:send, event})
end
