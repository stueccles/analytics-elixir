defmodule Segment.Analytics.AnalyticsTest do
  # not used in async mode because of Bypass
  # test fail randomly
  use ExUnit.Case
  import ExUnit.CaptureLog

  setup do
    bypass = Bypass.open()
    start_supervised({Segment, [key: "123", endpoint: endpoint_url(bypass.port)]})
    version = Mix.Project.get().project[:version]

    event = %Segment.Analytics.Track{
      userId: nil,
      event: "test1",
      properties: %{},
      context: %Segment.Analytics.Context{}
    }

    expected_request_body = %{
      "batch" => [
        %{
          "anonymousId" => nil,
          "context" => %{
            "app" => nil,
            "ip" => nil,
            "library" => %{
              "name" => "analytics_elixir",
              "transport" => "http",
              "version" => version
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
          "userId" => nil,
          "version" => nil
        }
      ]
    }

    expected_response = ~s({"another": {"json": ["response"]}}, "address":{"city": "Amsterdam"}})

    {:ok,
     bypass: bypass,
     event: event,
     expected_request_body: expected_request_body,
     expected_response: expected_response,
     version: version}
  end

  describe "call/2" do
    test "sends an event, and returns the response", %{
      bypass: bypass,
      event: event,
      expected_request_body: expected_request_body,
      expected_response: expected_response
    } do
      Bypass.expect(bypass, fn conn ->
        {:ok, received_body, _conn} = Plug.Conn.read_body(conn)

        # messageId and sentAt are not asserted
        %{"batch" => [received_event | _received_events]} =
          received_body
          |> Poison.decode!()
          |> Map.delete("sentAt")

        received_event = Map.delete(received_event, "messageId")

        assert %{"batch" => [received_event]} == expected_request_body
        Plug.Conn.resp(conn, 200, expected_response)
      end)

      log =
        capture_log(fn ->
          task = Segment.Analytics.call(event)
          assert {:ok, expected_response} == Task.await(task)
        end)

      assert log =~
               ~s([Segment.Analytics] call success: 200 with body: ) <>
                 ~s({"another": {"json": ["response"]}}, "address":{}})
    end

    test "when `drop_nil_fields` option is set to `true`, sends an event without " <>
           "null JSON attributes, and returns the response",
         %{
           bypass: bypass,
           event: event,
           expected_response: expected_response,
           version: version
         } do
      expected_request_body = %{
        "batch" => [
          %{
            "context" => %{
              "library" => %{
                "name" => "analytics_elixir",
                "transport" => "http",
                "version" => version
              }
            },
            "event" => "test1",
            "properties" => %{},
            "type" => "track"
          }
        ]
      }

      Bypass.expect(bypass, fn conn ->
        {:ok, received_body, _conn} = Plug.Conn.read_body(conn)

        # messageId and sentAt are not asserted
        %{"batch" => [received_event | _received_events]} =
          received_body
          |> Poison.decode!()
          |> Map.delete("sentAt")

        received_event = Map.delete(received_event, "messageId")

        assert %{"batch" => [received_event]} == expected_request_body
        Plug.Conn.resp(conn, 200, expected_response)
      end)

      task = Segment.Analytics.call(event, drop_nil_fields: true)
      assert {:ok, expected_response} == Task.await(task)
    end
  end

  describe "call/2 when another endpoint and key were given" do
    setup %{bypass: bypass} do
      Bypass.expect(bypass, fn _conn ->
        flunk("#{endpoint_url(bypass.port)} shouldn't be called")
      end)

      Bypass.pass(bypass)

      {:ok, bypass: Bypass.open()}
    end

    test "sends an event using endpoint and key from options, and returns the response", %{
      bypass: bypass,
      event: event,
      expected_request_body: expected_request_body,
      expected_response: expected_response
    } do
      Bypass.expect(bypass, fn conn ->
        {:ok, received_body, _conn} = Plug.Conn.read_body(conn)

        # messageId and sentAt are not asserted
        %{"batch" => [received_event | _received_events]} =
          received_body
          |> Poison.decode!()
          |> Map.delete("sentAt")

        received_event = Map.delete(received_event, "messageId")

        assert %{"batch" => [received_event]} == expected_request_body
        Plug.Conn.resp(conn, 200, expected_response)
      end)

      options = [key: "anotherkey", endpoint: endpoint_url(bypass.port)]

      task = Segment.Analytics.call(event, options)
      assert {:ok, expected_response} == Task.await(task)
    end

    test "when fail to reach the server returns error", %{event: event} do
      expected_response = ~s({"reason":":nxdomain"})

      options = [key: "invalidendpoint", endpoint: "http://invalidend.point"]

      log =
        capture_log(fn ->
          task = Segment.Analytics.call(event, options)
          assert {:error, expected_response} == Task.await(task)
        end)

      assert log =~
               ~s(call failed: %HTTPoison.Error{id: nil, reason: :nxdomain} with reason: :nxdomain)
    end
  end

  defp endpoint_url(port), do: "http://localhost:#{port}/"
end
