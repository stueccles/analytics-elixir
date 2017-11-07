defmodule Segment do
  alias Segment.Analytics.Http
  alias Segment.{Track, Identify, Screen, Alias, Group, Page, Context}
  @type status :: :ok | :error

  @spec start_link(binary) :: { Segment.status, pid }
  def start_link(write_key) do
    Agent.start_link(fn -> write_key end, name: __MODULE__)
  end

  def write_key() do
    Agent.get(__MODULE__, fn(state) -> state end)
  end

  def track(t = %Track{}) do
    call(t)
  end

  def track(user_id, event, properties \\ %{}, context \\ Context.new()) do
    %Track{userId: user_id, event: event, properties: properties, context: context}
    |> call
  end

  def identify(i = %Identify{}) do
    call(i)
  end

  def identify(user_id, traits \\ %{}, context \\ Context.new()) do
    %Identify{userId: user_id, traits: traits, context: context}
    |> call
  end

  def screen(s = %Screen{}) do
    call(s)
  end

  def screen(user_id, name \\ "", properties \\ %{}, context \\ Context.new()) do
    %Screen{userId: user_id, name: name, properties: properties, context: context}
    |> call
  end

  def alias(a = %Alias{}) do
    call(a)
  end

  def alias(user_id, previous_id, context \\ Context.new()) do
    %Alias{userId: user_id, previousId: previous_id, context: context}
    |> call
  end

  def group(g = %Group{}) do
    call(g)
  end

  def group(user_id, group_id, traits \\ %{}, context \\ Context.new()) do
    %Group{userId: user_id, groupId: group_id, traits: traits, context: context}
    |> call
  end

  def page(p = %Page{}) do
    call(p)
  end

  def page(user_id, name \\ "", properties \\ %{}, context \\ Context.new()) do
    %Page{userId: user_id, name: name, properties: properties, context: context}
    |> call
  end

  defp call(api) do
    Task.async(fn -> post_to_segment(api.method, Poison.encode!(api)) end)
  end

  defp post_to_segment(function, body) do
    Http.post(function, body)
    |> log_result(function, body)
  end

  defp log_result({_, %{status_code: code}}, function, body) when code in 200..299 do
    # success
    Logger.debug("Segment #{function} call success: #{code} with body: #{body}")
  end

  defp log_result({_, %{status_code: code}}, function, body) do
    # every other failure
    Logger.debug("Segment #{function} call failed: #{code} with body: #{body}")
  end
end
