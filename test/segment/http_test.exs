defmodule Segment.Analytics.HttpTest do
  use ExUnit.Case, async: true

  @apikey "afakekey"
  @url "something"
  @body ~s({"sample": "body"})

  setup do
    bypass = Bypass.open()
    Segment.start_link(@apikey, endpoint_url(bypass.port))

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
  end

  defp endpoint_url(port), do: "http://localhost:#{port}/"
end
