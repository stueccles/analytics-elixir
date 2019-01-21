defmodule SegmentTest do
  use ExUnit.Case

  doctest Segment

  @segment_test_key System.get_env("SEGMENT_KEY")

  test "track debugging" do
    Segment.start_link(@segment_test_key)
    t = Segment.Analytics.track("343434", "track debugging #{elem(:os.timestamp(), 2)}")
    Task.await(t)
  end
end
