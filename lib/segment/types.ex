defmodule Segment.Analytics.Types do
  def common_fields do
    [
      :anonymousId,
      :context,
      :integrations,
      :timestamp,
      :userId,
      :version
    ]
  end
end

defmodule Segment.Analytics.Track do
  @method "track"

  defstruct Segment.Analytics.Types.common_fields() ++
              [
                :event,
                :properties,
                type: @method
              ]

  def new(attrs) do
    struct(__MODULE__, attrs)
  end
end

defmodule Segment.Analytics.Identify do
  @method "identify"

  defstruct Segment.Analytics.Types.common_fields() ++
              [
                :traits,
                type: @method
              ]

  def new(attrs) do
    struct(__MODULE__, attrs)
  end
end

defmodule Segment.Analytics.Alias do
  @method "alias"

  defstruct Segment.Analytics.Types.common_fields() ++
              [
                :previousId,
                type: @method
              ]

  def new(attrs) do
    struct(__MODULE__, attrs)
  end
end

defmodule Segment.Analytics.Page do
  @method "page"

  defstruct Segment.Analytics.Types.common_fields() ++
              [
                :name,
                :properties,
                type: @method
              ]

  def new(attrs) do
    struct(__MODULE__, attrs)
  end
end

defmodule Segment.Analytics.Screen do
  @method "screen"

  defstruct Segment.Analytics.Types.common_fields() ++
              [
                :name,
                :properties,
                type: @method
              ]

  def new(attrs) do
    struct(__MODULE__, attrs)
  end
end

defmodule Segment.Analytics.Group do
  @method "group"

  defstruct Segment.Analytics.Types.common_fields() ++
              [
                :groupId,
                :traits,
                type: @method
              ]

  def new(attrs) do
    struct(__MODULE__, attrs)
  end
end

defmodule Segment.Analytics.Context do
  @library_name Mix.Project.get().project[:description]
  @library_version Mix.Project.get().project[:version]

  defstruct [
    :active,
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
    :groupId,
    :traits,
    :userAgent
  ]

  def update(context = %__MODULE__{}) do
    %{context | library: %{name: @library_name, version: @library_version}}
  end

  def new do
    update(%__MODULE__{})
  end

  def new(attrs) do
    struct(__MODULE__, attrs)
    |> update
  end
end
