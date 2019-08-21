defmodule Segment.Event do
  @moduledoc false

  alias Segment.Analytics.Track

  @types [:track, :identify, :screen, :alias, :group, :page]

  def new(id, {:track, name}) when is_binary(name) or is_atom(name) do
    %{event: name} |> Track.new() |> add_user_id(id)
  end

  def new(id, type) when type in @types do
    type |> dispatch_module() |> apply(:new, [%{}]) |> add_user_id(id)
  end

  defp dispatch_module(name) do
    Module.concat([
      Segment,
      Analytics,
      name |> to_string() |> String.capitalize()
    ])
  end

  def add_timestamp(event, data) when is_binary(data) do
    %{event | timestamp: data}
  end

  def add_timestamp(event, %DateTime{} = data) do
    add_timestamp(
      event,
      DateTime.to_iso8601(data)
    )
  end

  def add_timestamp(event, %NaiveDateTime{} = data) do
    add_timestamp(
      event,
      DateTime.from_naive!(data, "Etc/UTC")
    )
  end

  def add_context(event, data) when is_map(data) do
    %{event | context: data}
  end

  def add_anonymous_id(event, data) when is_binary(data) or is_integer(data) do
    %{event | anonymousId: data}
  end

  def add_integrations(event, data) when is_map(data) do
    %{event | integrations: data}
  end

  defp add_user_id(event, data) when is_binary(data) or is_integer(data) do
    %{event | userId: data }
  end

  def add_traits(e, data), do: AnalyticsFields.add_traits(e, data)
  def add_properties(e, data), do: AnalyticsFields.add_properties(e, data)
  def add_previous_id(e, data), do: AnalyticsFields.add_previous_id(e, data)
  def add_group_id(e, data), do: AnalyticsFields.add_group_id(e, data)
end

defprotocol AnalyticsFields do
  def add_traits(event, data)
  def add_properties(event, data)
  def add_previous_id(event, data)
  def add_group_id(event, data)
end

defimpl AnalyticsFields, for: Any do
  def add_traits(event, traits) when is_map(traits) do
    %{event | traits: traits}
  end

  def add_properties(event, properties) when is_map(properties) do
    %{event | properties: properties}
  end

  def add_group_id(event, id) when is_binary(id) or is_integer(id)do
    %{event | groupId: id}
  end

  def add_previous_id(event, id) when is_binary(id) or is_integer(id)do
    %{event | previousId: id}
  end
end
