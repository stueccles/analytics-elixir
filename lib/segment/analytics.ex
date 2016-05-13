defmodule Segment.Analytics do
  alias Segment.Analytics.Context
  alias Segment.Analytics.Http

  require Logger

  def track(t = %Segment.Analytics.Track{}) do
    call(t)
  end

  def track(user_id, event, properties \\ %{}, context \\ Context.new) do
    %Segment.Analytics.Track{ userId: user_id,
                              event: event,
                              properties: properties,
                              context: context }
    |> call
  end

  def identify(i = %Segment.Analytics.Identify{}) do
    call(i)
  end

  def identify(user_id, traits \\ %{}, context \\ Context.new) do
    %Segment.Analytics.Identify{  userId: user_id,
                                      traits: traits,
                                      context: context }
    |> call
  end

  def screen(s = %Segment.Analytics.Screen{}) do
    call(s)
  end

  def screen(user_id, name \\ "", properties \\ %{}, context \\ Context.new ) do
    %Segment.Analytics.Screen{  userId: user_id,
                                    name: name,
                                    properties: properties,
                                    context: context }
    |> call
  end

  def alias(a = %Segment.Analytics.Alias{}) do
    call(a)
  end

  def alias(user_id, previous_id, context \\ Context.new) do
    %Segment.Analytics.Alias{ userId: user_id,
                                  previousId: previous_id,
                                  context: context }
    |> call
  end

  def group(g = %Segment.Analytics.Group{}) do
    call(g)
  end

  def group(user_id, group_id, traits \\ %{}, context \\ Context.new) do
    %Segment.Analytics.Group{ userId: user_id,
                                  groupId: group_id,
                                  traits: traits,
                                  context: context }
    |> call
  end

  def page(p = %Segment.Analytics.Page{}) do
    call(p)
  end

  def page(user_id, name \\ "", properties \\ %{}, context \\ Context.new ) do
    %Segment.Analytics.Page{  userId: user_id,
                                  name: name,
                                  properties: properties,
                                  context: context }
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
    #success
    Logger.debug("Segment #{function} call success: #{code} with body: #{body}")
  end

  defp log_result({_, %{status_code: code}}, function, body) do
    #every other failure
    Logger.debug("Segment #{function} call failed: #{code} with body: #{body}")
  end
end
