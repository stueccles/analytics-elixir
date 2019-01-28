defmodule Segment.Analytics.AnalyticsTest do
  # not used in async mode because of Bypass
  # test fail randomly
  use ExUnit.Case

  setup do
    bypass = Bypass.open()
    Segment.start_link("123", endpoint_url(bypass.port))

    {:ok, bypass: bypass}
  end

  describe "batch_track/1" do
    test "send a batch event", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        body = ~s"""
        {
          "batch":[
            {
              "userId":null,
              "timestamp":null,
              "properties":{},
              "method":"track",
              "integrations":null,
              "event":"test1",
              "context":{},
              "anonymousId":null
            }
          ]
        }
        """

        assert {:ok, body, _conn} = Plug.Conn.read_body(conn)

        Plug.Conn.resp(conn, 200, "")
      end)

      events = [
        %Segment.Analytics.Track{
          userId: nil,
          event: "test1",
          properties: %{},
          context: %{}
        }
      ]

      task = Segment.Analytics.batch_track(events)
      Task.await(task)
    end
  end

  defp endpoint_url(port), do: "http://localhost:#{port}/"
end
