defmodule Segment.Analytics.Track do
  @derive [Poison.Encoder]
  @method "track"

  defstruct [ :userId,
              :event,
              :properties,
              :context,
              :timestamp,
              :integrations,
              :anonymousId,
              method: @method
            ]

end

defmodule Segment.Analytics.Identify do
  @derive [Poison.Encoder]
  @method "identify"

  defstruct [ :userId,
              :traits,
              :context,
              :timestamp,
              :integrations,
              :anonymousId,
              method: @method
            ]
end

defmodule Segment.Analytics.Alias do
  @derive [Poison.Encoder]
  @method "alias"

  defstruct [ :userId,
              :previousId,
              :context,
              :timestamp,
              :integrations,
              method: @method
            ]

end

defmodule Segment.Analytics.Page do
  @derive [Poison.Encoder]
  @method "page"

  defstruct [ :userId,
              :name,
              :properties,
              :context,
              :timestamp,
              :integrations,
              :anonymousId,
              method: @method]

end

defmodule Segment.Analytics.Screen do
  @derive [Poison.Encoder]
  @method "screen"

  defstruct [ :userId,
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

  defstruct [ :userId,
              :groupId,
              :traits,
              :context,
              :timestamp,
              :integrations,
              :anonymousId,
              method: @method
            ]
end

defmodule Segment.Analytics.Context do
  @derive [Poison.Encoder]
  @library_name Mix.Project.get().project[:description]
  @library_version Mix.Project.get().project[:version]

  defstruct [ :app,
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

    def update(context = %__MODULE__{}) do
      %{context | library: %{name: @library_name, version: @library_version}}
    end

    def new do
      update(%__MODULE__{})
    end

end
