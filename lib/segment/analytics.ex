defmodule Segment.Analytics do
  alias HTTPoison.{Error, Response}

  alias Segment.Analytics.{Batch, Context, Http, ResponseFormatter}
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
    |> ResponseFormatter.build(prefix: __MODULE__)
    |> tap(&MetaLogger.log(:debug, &1))
    |> handle_response()
  end

  defp handle_response(%{payload: %{data: %Response{body: body, status_code: status_code}}})
       when status_code in 200..299 do
    {:ok, body}
  end

  defp handle_response(%{payload: %{data: %Response{body: body}}}), do: {:error, body}

  defp handle_response(%{payload: %{data: %Error{reason: reason}}}) do
    {:error, Enum.join([~s({"reason":"), inspect(reason), ~s("})])}
  end
end
