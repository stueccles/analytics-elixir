defmodule SegmentTest do
  use ExUnit.Case

  test "track debugging" do
    test_began = :erlang.system_time()

    :telemetry.attach_many(
      self(),
      [[:segment, :batch, :start], [:segment, :batch, :stop]],
      fn n, m10s, m6a, pid -> send(pid, {:telemetry, n, m10s, m6a}) end,
      self()
    )

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

    test_ended = :erlang.system_time()

    assert_received {:telemetry, [:segment, :batch, :start], %{system_time: system_time},
                     %{events: events}}

    assert_received {:telemetry, [:segment, :batch, :stop], %{duration: duration},
                     %{events: ^events, status: :ok, result: {:ok, env}}}

    assert system_time > test_began
    assert system_time <= test_ended
    assert length(events) == 6
    assert duration <= test_ended - test_began
    assert env.status == 200
  end

  defp wait_random(n \\ 1000), do: Process.sleep(:rand.uniform(n))
end
