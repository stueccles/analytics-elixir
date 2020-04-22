defmodule SegmentTest do
  use ExUnit.Case

  test "track debugging" do
    Segment.start_link(System.get_env("SEGMENT_KEY"))

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

    Segment.Analytics.Batcher.flush()
  end

  defp wait_random(n \\ 1000), do: Process.sleep(:rand.uniform(n))
end
