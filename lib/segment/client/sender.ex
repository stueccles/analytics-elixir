defmodule Segment.Analytics.Sender do
  @moduledoc """

  """
  use GenServer
  alias Segment.Analytics.{Track, Identify, Screen, Alias, Group, Page}

  def start_link(api_key) do
    client = Segment.Http.client(api_key)
    GenServer.start_link(__MODULE__, client, name: __MODULE__)
  end

  # client
  def call(event = %Track{}), do: callp(event)
  def call(event = %Identify{}), do: callp(event)
  def call(event = %Screen{}), do: callp(event)
  def call(event = %Alias{}), do: callp(event)
  def call(event = %Group{}), do: callp(event)
  def call(event = %Page{}), do: callp(event)

  # GenServer Callbacks

  @impl true
  def init(client) do
    {:ok, client}
  end

  @impl true
  def handle_cast({:send, event}, client) do
    Task.async(fn -> Segment.Http.call(client, event) end)
    {:noreply, client}
  end

  # Helpers
  defp callp(event) do
    GenServer.cast(__MODULE__, {:send, event})
  end
end
