defmodule Segment.Analytics do
  @moduledoc """
    The `Segment.Analytics` module is the easiest way to send Segment events and provides convenience methods for `track`, `identify,` `screen`, `alias`, `group`, and `page` calls

    The functions will then delegate the call to the configured service implementation which can be changed with:
    ```elixir
    config :segment, sender_impl: Segment.Analytics.Batcher,
    ```
    By default (if no configuration is given) it will use `Segment.Analytics.Batcher` to send events in a batch periodically
  """
  alias Segment.Analytics.{Track, Identify, Screen, Context, Alias, Group, Page}

  @type segment_id :: String.t() | integer()

  @doc """
    Make a call to Segment with an event. Should be of type `Track, Identify, Screen, Alias, Group or Page`
  """
  @spec send(Segment.segment_event(), pid() | __MODULE__.t()) :: :ok
  def send(%{__struct__: mod} = event, pid \\ __MODULE__)
      when mod in [Track, Identify, Screen, Alias, Group, Page] do
    call(event, pid)
  end

  @doc """
    `track` lets you record the actions your users perform. Every action triggers what Segment call an “event”, which can also have associated properties as defined in the
    `Segment.Analytics.Track` struct

    See [https://segment.com/docs/spec/track/](https://segment.com/docs/spec/track/)
  """
  @spec track(Segment.Analytics.Track.t(), pid() | __MODULE__.t()) :: :ok
  def track(t = %Track{}, pid \\ __MODULE__), do: call(t, pid)

  @doc """
    `track` lets you record the actions your users perform. Every action triggers what Segment call an “event”, which can also have associated properties. `track/4` takes a `user_id`, an
    `event_name`, optional additional `properties` and an optional `Segment.Analytics.Context` struct.

    See [https://segment.com/docs/spec/track/](https://segment.com/docs/spec/track/)
  """
  @spec track(
          segment_id(),
          String.t(),
          map(),
          Segment.Analytics.Context.t(),
          pid() | __MODULE__.t()
        ) :: :ok
  def track(user_id, event_name, properties, context \\ Context.new(), pid \\ __MODULE__)
      when is_bitstring(event_name) do
    %Track{
      userId: user_id,
      event: event_name,
      properties: properties,
      context: context
    }
    |> call(pid)
  end

  @doc """
    `identify` lets you tie a user to their actions and record traits about them as defined in the
    `Segment.Analytics.Identify` struct

    See [https://segment.com/docs/spec/identify/](https://segment.com/docs/spec/identify/)
  """
  @spec identify(Segment.Analytics.Identify.t(), pid() | __MODULE__.t()) :: :ok
  def identify(i = %Identify{}, pid \\ __MODULE__), do: call(i, pid)

  @doc """
  `identify` lets you tie a user to their actions and record traits about them. `identify/3` takes a `user_id`, optional additional `traits` and an optional `Segment.Analytics.Context` struct.

  See [https://segment.com/docs/spec/identify/](https://segment.com/docs/spec/identify/)
  """
  @spec identify(segment_id(), map(), Segment.Analytics.Context.t(), pid() | __MODULE__.t()) ::
          :ok
  def identify(user_id, traits, context, pid \\ __MODULE__) do
    %Identify{userId: user_id, traits: traits, context: context}
    |> call(pid)
  end

  @doc """
    `screen` let you record whenever a user sees a screen of your mobile app with properties defined in the
    `Segment.Analytics.Screen` struct

  See [https://segment.com/docs/spec/screen/](https://segment.com/docs/spec/screen/)
  """
  @spec screen(Segment.Analytics.Screen.t(), pid() | __MODULE__.t()) :: :ok
  def screen(s = %Screen{}, pid \\ __MODULE__), do: call(s, pid)

  @doc """
  `screen` let you record whenever a user sees a screen of your mobile app. `screen/4` takes a `user_id`, an optional `screen_name`, optional `properties` and an optional `Segment.Analytics.Context` struct.

  See [https://segment.com/docs/spec/screen/](https://segment.com/docs/spec/screen/)
  """
  @spec screen(
          segment_id(),
          String.t(),
          map(),
          Segment.Analytics.Context.t(),
          pid() | __MODULE__.t()
        ) :: :ok
  def screen(user_id, screen_name, properties, context \\ Context.new(), pid \\ __MODULE__) do
    %Screen{
      userId: user_id,
      name: screen_name,
      properties: properties,
      context: context
    }
    |> call(pid)
  end

  @doc """
    `alias` is how you associate one identity with another with properties defined in the `Segment.Analytics.Alias` struct

  See [https://segment.com/docs/spec/alias/](https://segment.com/docs/spec/alias/)
  """
  @spec alias(Segment.Analytics.Alias.t(), pid() | __MODULE__.t()) :: :ok
  def alias(a = %Alias{}, pid \\ __MODULE__), do: call(a, pid)

  @doc """
  `alias` is how you associate one identity with another. `alias/3` takes a `user_id` and a `previous_id` to map from. It also takes an optional `Segment.Analytics.Context` struct.

  See [https://segment.com/docs/spec/alias/](https://segment.com/docs/spec/alias/)
  """
  @spec alias(segment_id(), segment_id(), Segment.Analytics.Context.t(), pid() | __MODULE__.t()) ::
          :ok
  def alias(user_id, previous_id, context, pid \\ __MODULE__) do
    %Alias{userId: user_id, previousId: previous_id, context: context}
    |> call(pid)
  end

  @doc """
  The `group` call is how you associate an individual user with a group with the properties in the defined in the `Segment.Analytics.Group` struct

  See [https://segment.com/docs/spec/group/](https://segment.com/docs/spec/group/)
  """
  @spec group(Segment.Analytics.Group.t(), pid() | __MODULE__.t()) :: :ok
  def group(g = %Group{}, pid \\ __MODULE__), do: call(g, pid)

  @doc """
  The `group` call is how you associate an individual user with a group. `group/4` takes a `user_id` and a `group_id` to associate it with. It also takes optional `traits` of the group and
  an optional `Segment.Analytics.Context` struct.

  See [https://segment.com/docs/spec/group/](https://segment.com/docs/spec/group/)
  """
  @spec group(
          segment_id(),
          segment_id(),
          map(),
          Segment.Analytics.Context.t(),
          pid() | __MODULE__.t()
        ) ::
          :ok
  def group(user_id, group_id, traits, context \\ Context.new(), pid \\ __MODULE__) do
    %Group{userId: user_id, groupId: group_id, traits: traits, context: context}
    |> call(pid)
  end

  @doc """
  The `page` call lets you record whenever a user sees a page of your website with the properties defined in the `Segment.Analytics.Page` struct

  See [https://segment.com/docs/spec/page/](https://segment.com/docs/spec/page/)
  """
  @spec page(Segment.Analytics.Page.t(), pid() | __MODULE__.t()) :: :ok
  def page(p = %Page{}, pid \\ __MODULE__), do: call(p, pid)

  @doc """
  The `page` call lets you record whenever a user sees a page of your website. `page/4` takes a `user_id` and an optional `page_name`, optional `properties` and an optional `Segment.Analytics.Context` struct.

  See [https://segment.com/docs/spec/page/](https://segment.com/docs/spec/page/)
  """
  @spec page(
          segment_id(),
          String.t(),
          map(),
          Segment.Analytics.Context.t(),
          pid() | __MODULE__.t()
        ) :: :ok
  def page(user_id, page_name, properties, context \\ Context.new(), pid \\ __MODULE__) do
    %Page{userId: user_id, name: page_name, properties: properties, context: context}
    |> call(pid)
  end

  @spec call(Segment.segment_event(), pid() | __MODULE__.t()) :: :ok
  def call(event, pid \\ __MODULE__), do: Segment.Config.service().call(event, pid)
end
