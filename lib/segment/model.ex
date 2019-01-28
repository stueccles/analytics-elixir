defmodule Segment.Analytics.BatchTrack do
  @derive {Poison.Encoder, except: [:method]}
  @method "track"

  defstruct [
    :batch,
    method: @method
  ]
end

defmodule Segment.Analytics.Track do
  @derive [Poison.Encoder]
  @method "track"

  defstruct [
    :userId,
    :event,
    :properties,
    :context,
    :timestamp,
    :integrations,
    :anonymousId,
    :sentAt,
    method: @method
  ]
end

defmodule Segment.Analytics.Identify do
  @derive [Poison.Encoder]
  @method "identify"

  defstruct [:userId, :traits, :context, :timestamp, :integrations, :anonymousId, method: @method]
end

defmodule Segment.Analytics.Alias do
  @derive [Poison.Encoder]
  @method "alias"

  defstruct [:userId, :previousId, :context, :timestamp, :integrations, method: @method]
end

defmodule Segment.Analytics.Page do
  @derive [Poison.Encoder]
  @method "page"

  defstruct [
    :userId,
    :name,
    :properties,
    :context,
    :timestamp,
    :integrations,
    :anonymousId,
    method: @method
  ]
end

defmodule Segment.Analytics.Screen do
  @derive [Poison.Encoder]
  @method "screen"

  defstruct [
    :userId,
    :name,
    :properties,
    :context,
    :timestamp,
    :integrations,
    :anonymousId,
    method: @method
  ]
end

defmodule Segment.Analytics.Group do
  @derive [Poison.Encoder]
  @method "group"

  defstruct [
    :userId,
    :groupId,
    :traits,
    :context,
    :timestamp,
    :integrations,
    :anonymousId,
    method: @method
  ]
end

defmodule Segment.Analytics.Context.Library do
  @derive [Poison.Encoder]

  @project_name Mix.Project.get().project[:name]
  @project_version Mix.Project.get().project[:version]

  defstruct [:name, :version, :transport]

  def build() do
    %__MODULE__{
      name: @project_name,
      version: @project_version,
      # the only supported by the library for now.
      transport: "http"
    }
  end
end

defmodule Segment.Analytics.Context do
  @derive [Poison.Encoder]
  defstruct [
    :app,
    :campaign,
    :device,
    :ip,
    :library,
    :locale,
    :location,
    :network,
    :os,
    :page,
    :referrer,
    :screen,
    :timezone,
    :traits,
    :userAgent
  ]
end
