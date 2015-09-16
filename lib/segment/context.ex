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

    def update(context = %Segment.Analytics.Context{}) do
      %{context | library: %{name: @library_name, version: @library_version}}
    end

    def new do
      update(%Segment.Analytics.Context{})
    end

end
