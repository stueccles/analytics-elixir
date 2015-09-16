defmodule Segment do

  @type status :: :ok | :error

  @spec start_link(binary) :: { Segment.status, pid }
  def start_link(write_key) do
    Agent.start_link(fn -> write_key end, name: __MODULE__)
  end

  def write_key() do
    Agent.get(__MODULE__, fn(state) -> state end)
  end

end
