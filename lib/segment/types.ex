defmodule Segment.Analytics.Types do
  @moduledoc false
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
  @moduledoc false
  @method "track"

  defstruct Segment.Analytics.Types.common_fields() ++
              [
                :event,
                :properties,
                type: @method
              ]

  @type t :: %__MODULE__{}

  def new(attrs) do
    struct(__MODULE__, attrs)
  end
end

defmodule Segment.Analytics.Identify do
  @moduledoc false
  @method "identify"

  defstruct Segment.Analytics.Types.common_fields() ++
              [
                :traits,
                type: @method
              ]

  @type t :: %__MODULE__{}

  def new(attrs) do
    struct(__MODULE__, attrs)
  end
end

defmodule Segment.Analytics.Alias do
  @moduledoc false
  @method "alias"

  defstruct Segment.Analytics.Types.common_fields() ++
              [
                :previousId,
                type: @method
              ]

  @type t :: %__MODULE__{}

  def new(attrs) do
    struct(__MODULE__, attrs)
  end
end

defmodule Segment.Analytics.Page do
  @moduledoc false
  @method "page"

  defstruct Segment.Analytics.Types.common_fields() ++
              [
                :name,
                :properties,
                type: @method
              ]

  @type t :: %__MODULE__{}

  def new(attrs) do
    struct(__MODULE__, attrs)
  end
end

defmodule Segment.Analytics.Screen do
  @moduledoc false
  @method "screen"

  defstruct Segment.Analytics.Types.common_fields() ++
              [
                :name,
                :properties,
                type: @method
              ]

  @type t :: %__MODULE__{}

  def new(attrs) do
    struct(__MODULE__, attrs)
  end
end

defmodule Segment.Analytics.Group do
  @moduledoc false
  @method "group"

  defstruct Segment.Analytics.Types.common_fields() ++
              [
                :groupId,
                :traits,
                type: @method
              ]

  @type t :: %__MODULE__{}

  def new(attrs) do
    struct(__MODULE__, attrs)
  end
end

defmodule Segment.Analytics.Context do
  @moduledoc false
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

  @type t :: %__MODULE__{}

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
