defmodule Segment do
  use Agent

  @type status :: :ok | :error

  @default_endpoint "https://api.segment.io/v1/"

  @spec start_link(String.t(), String.t()) :: {Segment.status(), pid}
  def start_link(key, endpoint \\ @default_endpoint) do
    Agent.start_link(fn -> %{endpoint: endpoint, key: key} end, name: __MODULE__)
  end

  @doc """
  Returns the segment key

  ## Examples

    iex> Segment.start_link("key")
    ...> Segment.key()
    "key"

  """
  def key() do
    Agent.get(__MODULE__, &Map.get(&1, :key))
  end

  @doc """
  Returns the segment endpoint

  ## Examples

    iex> Segment.start_link("key")
    ...> Segment.endpoint()
    "https://api.segment.io/v1/"

    iex> Segment.start_link("key", "https://example.com")
    ...> Segment.endpoint()
    "https://example.com"

  """
  def endpoint() do
    Agent.get(__MODULE__, &Map.get(&1, :endpoint))
  end
end
