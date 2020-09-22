defmodule SegmentTest do
  use ExUnit.Case

  doctest Segment

  @segment_test_key System.get_env("SEGMENT_KEY")

  setup do
    {:ok, config: [key: @segment_test_key, endpoint: "https://api.segment.io/v1/track"]}
  end

  test "tracks debugging", %{config: config} do
    start_supervised!({Segment, config})

    t = Segment.Analytics.track("343434", "track debugging #{elem(:os.timestamp(), 2)}")
    Task.await(t)
  end

  describe "key/0" do
    test "returns segment key", %{config: config} do
      start_supervised!({Segment, config})

      assert Segment.key() == Keyword.get(config, :key)
    end

    test "when agent was not started, raises an error" do
      assert {:noproc, {GenServer, :call, [Segment, {:get, _function}, 5000]}} =
               catch_exit(Segment.key())
    end
  end

  describe "endpoint/0" do
    test "returns segment endpoint", %{config: config} do
      start_supervised!({Segment, config})

      assert Segment.endpoint() == Keyword.get(config, :endpoint)
    end

    test "when agent was not started, returns nil" do
      assert {:noproc, {GenServer, :call, [Segment, {:get, _function}, 5000]}} =
               catch_exit(Segment.endpoint())
    end
  end
end
