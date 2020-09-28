defmodule Segment.Analytics.AnalyticsTest do
  # not used in async mode because of Bypass
  # test fail randomly
  use ExUnit.Case

  setup do
    bypass = Bypass.open()
    start_supervised({Segment, [key: "123", endpoint: endpoint_url(bypass.port)]})

    {:ok, bypass: bypass}
  end

  describe "track/1" do
    test "sends a track event", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        {:ok, received_body, _conn} = Plug.Conn.read_body(conn)

        assert %{
                 "batch" => [
                   %{
                     "userId" => nil,
                     "type" => "track",
                     "timestamp" => nil,
                     "properties" => %{},
                     "event" => "test1",
                     "context" => %{
                       "app" => nil,
                       "ip" => nil,
                       "library" => %{
                         "name" => "analytics_elixir",
                         "transport" => "http",
                         "version" => "0.2.0"
                       },
                       "location" => nil,
                       "os" => nil,
                       "page" => nil,
                       "referrer" => nil,
                       "screen" => nil,
                       "timezone" => nil,
                       "traits" => nil,
                       "userAgent" => nil
                     },
                     "anonymousId" => nil
                   }
                 ]
               } = Poison.decode!(received_body)

        # messageId and sentAt are not asserted

        Plug.Conn.resp(conn, 200, "")
      end)

      event = %Segment.Analytics.Track{
        userId: nil,
        event: "test1",
        properties: %{},
        context: %Segment.Analytics.Context{}
      }

      task = Segment.Analytics.track(event)
      Task.await(task)
    end
  end

  describe "call/2" do
    test "sends an event", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        {:ok, received_body, _conn} = Plug.Conn.read_body(conn)

        assert %{
                 "batch" => [
                   %{
                     "anonymousId" => nil,
                     "context" => %{
                       "app" => nil,
                       "ip" => nil,
                       "library" => %{
                         "name" => "analytics_elixir",
                         "transport" => "http",
                         "version" => "0.2.0"
                       },
                       "location" => nil,
                       "os" => nil,
                       "page" => nil,
                       "referrer" => nil,
                       "screen" => nil,
                       "timezone" => nil,
                       "traits" => nil,
                       "userAgent" => nil
                     },
                     "event" => "test1",
                     "properties" => %{},
                     "timestamp" => nil,
                     "type" => "track",
                     "userId" => nil
                   }
                 ]
               } = Poison.decode!(received_body)

        # messageId and sentAt are not asserted

        Plug.Conn.resp(conn, 200, "")
      end)

      event = %Segment.Analytics.Track{
        userId: nil,
        event: "test1",
        properties: %{},
        context: %Segment.Analytics.Context{}
      }

      task = Segment.Analytics.call(event)
      Task.await(task)
    end

    test "sends an event using endpoint and key from options", %{bypass: bypass} do
      Bypass.expect(bypass, fn _conn ->
        flunk("#{endpoint_url(bypass.port)} shouldn't be called")
      end)

      Bypass.pass(bypass)

      another_bypass = Bypass.open()

      Bypass.expect(another_bypass, fn conn ->
        {:ok, received_body, _conn} = Plug.Conn.read_body(conn)

        assert %{
                 "batch" => [
                   %{
                     "userId" => nil,
                     "type" => "track",
                     "timestamp" => nil,
                     "properties" => %{},
                     "event" => "test1",
                     "context" => %{
                       "app" => nil,
                       "ip" => nil,
                       "library" => %{
                         "version" => "0.2.0",
                         "transport" => "http",
                         "name" => "analytics_elixir"
                       },
                       "location" => nil,
                       "os" => nil,
                       "page" => nil,
                       "referrer" => nil,
                       "screen" => nil,
                       "timezone" => nil,
                       "traits" => nil,
                       "userAgent" => nil
                     },
                     "anonymousId" => nil
                   }
                 ]
               } = Poison.decode!(received_body)

        # messageId and sentAt are not asserted

        Plug.Conn.resp(conn, 200, "")
      end)

      event = %Segment.Analytics.Track{
        userId: nil,
        event: "test1",
        properties: %{},
        context: %Segment.Analytics.Context{}
      }

      options = [key: "anotherkey", endpoint: endpoint_url(another_bypass.port)]

      task = Segment.Analytics.call(event, options)
      Task.await(task)
    end
  end

  defp endpoint_url(port), do: "http://localhost:#{port}/"
end
