defmodule Segment.Analytics do
  alias Segment.Analytics.Context
  alias Segment.Analytics.Http

  require Logger

  def track(t = %Segment.Analytics.Track{}), do: call(t)

  def track(user_id, event, properties \\ %{}, context \\ %Context{}) do
    %Segment.Analytics.Track{
      userId: user_id,
      event: event,
      properties: properties,
      context: context
    }
    |> call
  end

  def identify(i = %Segment.Analytics.Identify{}), do: call(i)

  def identify(user_id, traits \\ %{}, context \\ %Context{}) do
    %Segment.Analytics.Identify{
      userId: user_id,
      traits: traits,
      context: context
    }
    |> call
  end

  def screen(s = %Segment.Analytics.Screen{}), do: call(s)

  def screen(user_id, name \\ "", properties \\ %{}, context \\ %Context{}) do
    %Segment.Analytics.Screen{
      userId: user_id,
      name: name,
      properties: properties,
      context: context
    }
    |> call
  end

  def alias(a = %Segment.Analytics.Alias{}), do: call(a)

  def alias(user_id, previous_id, context \\ %Context{}) do
    %Segment.Analytics.Alias{
      userId: user_id,
      previousId: previous_id,
      context: context
    }
    |> call
  end

  def group(g = %Segment.Analytics.Group{}), do: call(g)

  def group(user_id, group_id, traits \\ %{}, context \\ %Context{}) do
    %Segment.Analytics.Group{
      userId: user_id,
      groupId: group_id,
      traits: traits,
      context: context
    }
    |> call
  end

  def page(p = %Segment.Analytics.Page{}), do: call(p)

  def page(user_id, name \\ "", properties \\ %{}, context \\ %Context{}) do
    %Segment.Analytics.Page{
      userId: user_id,
      name: name,
      properties: properties,
      context: context
    }
    |> call
  end

  def call(model, options \\ []) do
    batch =
      model
      |> generate_message_id()
      |> fill_context()
      |> wrap_in_batch()
      |> Poison.encode!()

    Task.async(fn -> post_to_segment(batch, options) end)
  end

  # TODO: replace with an actual buffering
  # to send events in batches rather than one by one
  # The idea is to reduce the traffic to the segment service
  defp wrap_in_batch(model) do
    %Segment.Analytics.Batch{
      batch: [model],
      sentAt: :os.system_time(:milli_seconds)
    }
  end

  defp fill_context(model) do
    put_in(model.context.library, Segment.Analytics.Context.Library.build())
  end

  defp generate_message_id(model) do
    put_in(model.messageId, UUID.uuid4())
  end

  defp post_to_segment(body, options) do
    Http.post("", body, options)
    |> log_result(body)
  end

  # log success responses
  defp log_result({_, %{status_code: code}}, body) when code in 200..299 do
    Logger.debug("[#{__MODULE__}] call success: #{code} with body: #{body}")
  end

  # log failed responses
  defp log_result(error, body) do
    Logger.debug("[#{__MODULE__}] call failed: #{inspect(error)} with body: #{body}")
  end
end
