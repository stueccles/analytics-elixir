defmodule Segment.Support.Factory do
  alias Segment.Analytics.{Batch, Context, Track}

  defmodule Properties, do: defstruct([:foo, :bar, :baz, :qux, :corge, :grault, :garply, :waldo])
  defmodule NestedProperties, do: defstruct([:foo, :bar, :baz, :qux])

  def build(:batch) do
    %Batch{
      batch: [
        %Track{
          context: %Context{app: %{name: "analytics_elixir", version: "1.0.0"}},
          messageId: "e66f98cf-3a99-4895-a0a3-d5e6f72eeb23",
          properties: %Properties{
            bar: 2.5,
            baz: "baz",
            corge: [
              %{bar: 2.5, baz: "baz", foo: 1, qux: nil},
              %{}
            ],
            foo: 1,
            garply: %{foo: 1, bar: 2.5, baz: "baz", qux: nil},
            grault: [
              %NestedProperties{bar: 2.5, baz: "baz", foo: 1, qux: nil},
              %NestedProperties{}
            ],
            qux: nil,
            waldo: %NestedProperties{bar: 2.5, baz: "baz", foo: 1, qux: nil}
          }
        }
      ],
      sentAt: 1_608_657_553_311
    }
  end

  def map_for(:app), do: %{name: "analytics_elixir", version: "1.0.0"}

  def map_for(:batch), do: %{batch: [map_for(:track)], sentAt: 1_608_657_553_311}

  def map_for(:batch_without_null),
    do: %{batch: [map_for(:track_without_null)], sentAt: 1_608_657_553_311}

  def map_for(:context) do
    %{
      app: map_for(:app),
      ip: nil,
      library: nil,
      location: nil,
      os: nil,
      page: nil,
      referrer: nil,
      screen: nil,
      timezone: nil,
      traits: nil,
      userAgent: nil
    }
  end

  def map_for(:context_without_null), do: %{app: map_for(:app)}

  def map_for(:properties) do
    %{
      baz: "baz",
      bar: 2.5,
      corge: [
        %{bar: 2.5, baz: "baz", foo: 1, qux: nil},
        %{}
      ],
      foo: 1,
      garply: %{bar: 2.5, baz: "baz", foo: 1, qux: nil},
      grault: [
        %{bar: 2.5, baz: "baz", foo: 1, qux: nil},
        %{bar: nil, baz: nil, foo: nil, qux: nil}
      ],
      qux: nil,
      waldo: %{bar: 2.5, baz: "baz", foo: 1, qux: nil}
    }
  end

  def map_for(:properties_without_null) do
    %{
      baz: "baz",
      bar: 2.5,
      corge: [
        %{bar: 2.5, baz: "baz", foo: 1},
        %{}
      ],
      foo: 1,
      garply: %{bar: 2.5, baz: "baz", foo: 1},
      grault: [
        %{bar: 2.5, baz: "baz", foo: 1},
        %{}
      ],
      waldo: %{bar: 2.5, baz: "baz", foo: 1}
    }
  end

  def map_for(:track) do
    %{
      anonymousId: nil,
      context: map_for(:context),
      event: nil,
      messageId: "e66f98cf-3a99-4895-a0a3-d5e6f72eeb23",
      properties: map_for(:properties),
      timestamp: nil,
      type: "track",
      userId: nil,
      version: nil
    }
  end

  def map_for(:track_without_null) do
    %{
      context: map_for(:context_without_null),
      messageId: "e66f98cf-3a99-4895-a0a3-d5e6f72eeb23",
      properties: map_for(:properties_without_null),
      type: "track"
    }
  end
end
