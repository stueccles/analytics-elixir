defmodule Segment.Analytics.Sender do
  @moduledoc """

  """
  use GenServer
  alias Segment.Analytics.{Track, Identify, Screen, Alias, Group, Page}

  def start_link(api_key) do
    client = Segment.Http.client(api_key)
    GenServer.start_link(__MODULE__, client, name: __MODULE__)
  end

  def start_link(api_key, adapter) do
    client = Segment.Http.client(api_key, adapter)
    GenServer.start_link(__MODULE__, {client, :queue.new()}, name: __MODULE__)
  end

  # client
  def call(%{__struct__: mod} = event)
      when mod in [Track, Identify, Screen, Alias, Group, Page] do
    callp(event)
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
  defp callp(event) do
    GenServer.cast(__MODULE__, {:send, event})
  end
end
