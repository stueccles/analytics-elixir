defmodule SegmentTest do
  use ExUnit.Case

  @segment_test_key System.get_env("SEGMENT_KEY")

  test "track debugging" do
    n = 1000

    Segment.start_link(@segment_test_key)
    Segment.Analytics.track("343434", "track debugging #{elem(:os.timestamp(), 2)}")
    Process.sleep(:rand.uniform(n))
    Segment.Analytics.track("343434", "track debugging #{elem(:os.timestamp(), 2)}")
    Process.sleep(:rand.uniform(n))
    Segment.Analytics.track("343434", "track debugging #{elem(:os.timestamp(), 2)}")
    Process.sleep(:rand.uniform(n))
    Segment.Analytics.track("343434", "track debugging #{elem(:os.timestamp(), 2)}")
    Process.sleep(:rand.uniform(n))
    Segment.Analytics.track("343434", "track debugging #{elem(:os.timestamp(), 2)}")

    # wait 5 seconds for batcher
    Process.sleep(5000)
  end
end
