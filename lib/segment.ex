defmodule Segment do
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  @type segment_event ::
          Segment.Analytics.Track.t()
          | Segment.Analytics.Identify.t()
          | Segment.Analytics.Screen.t()
          | Segment.Analytics.Alias.t()
          | Segment.Analytics.Group.t()
          | Segment.Analytics.Page.t()

  @doc """
  Start the configured GenServer for handling Segment events with the Segment HTTP Source API Write Key

  By default if nothing is configured it will start `Segment.Analytics.Batcher`
  """
  @spec start_link(String.t()) :: GenServer.on_start()
  def start_link(api_key) do
    Segment.Config.service().start_link(api_key)
  end

  @doc """
  Start the configured GenServer for handling Segment events with the Segment HTTP Source API Write Key and a custom Tesla Adapter.

  By default if nothing is configured it will start `Segment.Analytics.Batcher`
  """
  @spec start_link(String.t(), Segment.Http.adapter()) :: GenServer.on_start()
  def start_link(api_key, adapter) do
    Segment.Config.service().start_link(api_key, adapter)
  end

  @spec child_spec(map()) :: map()
  def child_spec(opts) do
    Segment.Config.service().child_spec(opts)
  end
end
