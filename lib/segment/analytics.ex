defmodule Segment.Analytics do
  alias Segment.Analytics.{Track, Identify, Screen, Context, Alias, Group, Page}

  @service Application.get_env(:segment, :sender_impl, Segment.Analytics.Batcher)

  def track(t = %Track{}) do
    call(t)
  end

  def track(user_id, event, properties \\ %{}, context \\ Context.new()) do
    %Track{
      userId: user_id,
      event: event,
      properties: properties,
      context: context
    }
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
    %Screen{
      userId: user_id,
      name: name,
      properties: properties,
      context: context
    }
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

  defdelegate call(event), to: @service
end
