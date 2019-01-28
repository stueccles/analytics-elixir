defmodule Segment.Analytics.Context.LibraryTest do
  # not used in async mode because of Bypass
  # test fail randomly
  use ExUnit.Case

  alias Segment.Analytics.Context.Library

  describe "build/1" do
    test "builds the library struct with the default values" do
      assert %Library{
               name: Mix.Project.get().project[:name],
               transport: "http",
               version: Mix.Project.get().project[:version]
             } == Library.build()
    end
  end
end
