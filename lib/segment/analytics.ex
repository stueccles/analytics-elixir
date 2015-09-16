defmodule Segment.Analytics do
  alias Segment.Analytics.Context
  alias Segment.Analytics.Http

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

  defp call(method, body) do
    Http.post(method, [body: Poison.encode!(body), stream_to: self])
  end
end
