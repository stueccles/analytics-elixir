defmodule Segment.Analytics.HttpTest do
  # not used in async mode because of Bypass
  # test fail randomly
  use ExUnit.Case

  @apikey "afakekey"
  @url "something"
  @body ~s({"sample": "body"})

  setup do
    bypass = Bypass.open()
    start_supervised!({Segment, [key: @apikey, endpoint: endpoint_url(bypass.port)]})

    {:ok, bypass: bypass}
  end

  describe "post/4" do
    test "the request sent is correct", %{bypass: bypass} do
      Bypass.expect(bypass, "POST", "/#{@url}", fn conn ->
        [
          {"accept", "application/json"},
          {"content-type", "application/json"},
          {"x-api-key", @apikey}
        ]
        |> Enum.each(fn {header, value} ->
          assert [value] == Plug.Conn.get_req_header(conn, header)
        end)

        assert {:ok, @body, _conn} = Plug.Conn.read_body(conn)

        Plug.Conn.resp(conn, 200, "")
      end)

      Segment.Analytics.Http.post(@url, @body, [])
    end

    test "when endpoint and key are given via options, " <>
           "sends the request to the correct endpoint",
         %{bypass: bypass} do
      Bypass.expect(bypass, "POST", "/#{@url}", fn _conn ->
        flunk("#{endpoint_url(bypass.port)} shouldn't be called")
      end)

      Bypass.pass(bypass)

      another_bypass = Bypass.open()
      another_apikey = "foobarbaz"
      options = [key: another_apikey, endpoint: endpoint_url(another_bypass.port)]

      Bypass.expect(another_bypass, "POST", "/#{@url}", fn conn ->
        [
          {"accept", "application/json"},
          {"content-type", "application/json"},
          {"x-api-key", another_apikey}
        ]
        |> Enum.each(fn {header, value} ->
          assert [value] == Plug.Conn.get_req_header(conn, header)
        end)

        assert {:ok, @body, _conn} = Plug.Conn.read_body(conn)

        Plug.Conn.resp(conn, 200, "")
      end)

      Segment.Analytics.Http.post(@url, @body, options)
    end
  end

  def endpoint_url(port), do: "http://localhost:#{port}/"
end
