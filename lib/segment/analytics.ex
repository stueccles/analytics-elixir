defmodule Segment.Analytics do
  alias Segment.Analytics.Context
  alias Segment.Analytics.Http

  require Logger

  def track(t = %Segment.Analytics.Track{}) do
    call("track", t)
  end

  def track(user_id, event, properties \\ %{}, context \\ Context.new) do
    %Segment.Analytics.Track{ userId: user_id,
                              event: event,
                              properties: properties,
                              context: context }
    |> track

  end

  def identify(i = %Segment.Analytics.Identify{}) do
    call("identify", i)
  end

  def identify(user_id, traits \\ %{}, context \\ Context.new) do
    %Segment.Analytics.Identify{  userId: user_id,
                                      traits: traits,
                                      context: context }
    |> identify
  end

  def screen(s = %Segment.Analytics.Screen{}) do
    call("screen", s)
  end

  def screen(user_id, name \\ "", properties \\ %{}, context \\ Context.new ) do
    %Segment.Analytics.Screen{  userId: user_id,
                                    name: name,
                                    properties: properties,
                                    context: context }
    |> screen
  end

  def alias(a = %Segment.Analytics.Alias{}) do
    call("alias", a)
  end

  def alias(user_id, previous_id, context \\ Context.new) do
    %Segment.Analytics.Alias{ userId: user_id,
                                  previousId: previous_id,
                                  context: context }
    |> Segment.Analytics.alias
  end

  def group(g = %Segment.Analytics.Group{}) do
    call("group", g)
  end

  def group(user_id, group_id, traits \\ %{}, context \\ Context.new) do
    %Segment.Analytics.Group{ userId: user_id,
                                  groupId: group_id,
                                  traits: traits,
                                  context: context }
    |> group
  end

  def page(p = %Segment.Analytics.Page{}) do
    call("page", p)
  end

  def page(user_id, name \\ "", properties \\ %{}, context \\ Context.new ) do
    %Segment.Analytics.Page{  userId: user_id,
                                  name: name,
                                  properties: properties,
                                  context: context }
    |> page
  end

  defp call(function, params) do
    Task.async(fn -> post_to_segment(function, Poison.encode!(params)) end)
  end

  defp post_to_segment(function, body) do
    response = Http.post(function, [body: body]) |> log_result(function, body)
  end

  defp log_result(%{status_code: code}, function, body) when code in 200..299 do
    #success
    Logger.debug("Segment #{function} call success: #{code} with body: #{body}")

  end

  defp log_result(%{status_code: code}, function, body) do
    #every other failure
    Logger.debug("Segment #{function} call failed: #{code} with body: #{body}")
  end
end
