defmodule Segment do
  @moduledoc """
  Provides the api for sending data to Segment.io.
  """

  alias Segment.{Track, Identify, Screen, Alias, Group, Page, Context}

  @module Application.get_env(:segment, :api) || Segment.Server

  defdelegate send_track(t), to: @module
  defdelegate send_track(user_id, event, properties \\ %{}, context \\ Context.new()), to: @module

  defdelegate send_identify(i), to: @module
  defdelegate send_identify(user_id, traits \\ %{}, context \\ Context.new()), to: @module

  defdelegate send_screen(s), to: @module
  defdelegate send_screen(user_id, name \\ "", properties \\ %{}, context \\ Context.new()), to: @module

  defdelegate send_alias(a), to: @module
  defdelegate send_alias(user_id, previous_id, context \\ Context.new()), to: @module

  defdelegate send_group(g), to: @module
  defdelegate send_group(user_id, group_id, traits \\ %{}, context \\ Context.new()), to: @module

  defdelegate send_page(p), to: @module
  defdelegate send_page(user_id, name \\ "", properties \\ %{}, context \\ Context.new()), to: @module
end
