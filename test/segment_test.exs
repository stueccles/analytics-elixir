defmodule SegmentTest do
  use ExUnit.Case

  @segment_test_key System.get_env("SEGMENT_KEY")

  test "track debugging" do
    Segment.start_link(@segment_test_key)

    Segment.Analytics.track("user1", "track debugging #{elem(:os.timestamp(), 2)}")

    wait_random()

    Segment.Analytics.identify("user1", %{
      debug: "identify debugging #{elem(:os.timestamp(), 2)}"
    })

    wait_random()

    Segment.Analytics.screen("user1", "screen debugging #{elem(:os.timestamp(), 2)}")

    wait_random()

    Segment.Analytics.alias("user1", "user2")

    wait_random()

    Segment.Analytics.group("user1", "group1", %{
      debug: "group debugging #{elem(:os.timestamp(), 2)}"
    })

    wait_random()

    Segment.Analytics.page("user1", "page debugging #{elem(:os.timestamp(), 2)}")

    # wait 5 seconds for batcher
    Process.sleep(5000)
  end

  defp wait_random(n \\ 1000), do: Process.sleep(:rand.uniform(n))
end
