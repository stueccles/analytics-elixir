defmodule Segment.Analytics do
  require Logger

  alias Segment.Analytics.{Batch, Context, Http}
  alias Segment.Encoder

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
    Task.async(fn ->
      model
      |> generate_message_id()
      |> fill_context()
      |> wrap_in_batch()
      |> Encoder.encode!(options)
      |> post_to_segment(options)
    end)
  end

  defp generate_message_id(model), do: put_in(model.messageId, UUID.uuid4())

  defp fill_context(model),
    do: put_in(model.context.library, Context.Library.build())

  # TODO: replace with an actual buffering
  # to send events in batches rather than one by one
  # The idea is to reduce the traffic to the segment service
  defp wrap_in_batch(model) do
    %Batch{
      batch: [model],
      sentAt: :os.system_time(:milli_seconds)
    }
  end

  defp post_to_segment(body, options) do
    Http.post("", body, options)
    |> log_and_return(body)
  end

  # log success responses
  defp log_and_return({_, %{body: response_body, status_code: code}}, body)
       when code in 200..299 do
    Logger.debug("[#{__MODULE__}] call success: #{code} with body: #{body}")
    {:ok, response_body}
  end

  # log failed responses
  defp log_and_return({_, %{body: response_body}} = error, body) do
    Logger.debug("[#{__MODULE__}] call failed: #{inspect(error)} with body: #{body}")
    {:error, response_body}
  end

  defp log_and_return({_, %{reason: reason}} = error, body) do
    Logger.debug("[#{__MODULE__}] call failed: #{inspect(error)} with body: #{body}")
    {:error, Enum.join([~s({"reason":"), inspect(reason), ~s("})])}
  end
end
