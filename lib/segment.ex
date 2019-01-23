defmodule Segment do
  use Agent

  @type status :: :ok | :error

  @default_endpoint "https://api.segment.io/v1/"

  @spec start_link(String.t(), String.t()) :: {Segment.status(), pid}
  def start_link(key, endpoint \\ @default_endpoint) do
    Agent.start_link(fn -> %{endpoint: endpoint, key: key} end, name: __MODULE__)
  end

  @doc """
  The child specifications

  ## Examples

    iex> Segment.child_spec([key: "something"])
    %{
      id: Segment,
      start: {Segment, :start_link, ["something", nil]}
    }

    iex> Segment.child_spec([])
    ** (KeyError) key :key not found in: []

    iex> Segment.child_spec([key: "something", endpoint: "http://example.com"])
    %{
      id: Segment,
      start: {Segment, :start_link, ["something", "http://example.com"]}
    }

  """
  def child_spec(arg) do
    opts = [
      Keyword.fetch!(arg, :key),
      Keyword.get(arg, :endpoint)
    ]

    %{
      id: Segment,
      start: {Segment, :start_link, opts}
    }
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
