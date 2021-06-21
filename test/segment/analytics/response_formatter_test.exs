defmodule Segment.Analytics.ResponseFormatterTest do
  use ExUnit.Case, async: true

  alias Segment.Analytics.ResponseFormatter, as: Subject

  doctest Subject

  alias HTTPoison.{Error, Request, Response}

  setup do
    error = %Error{reason: "foo"}

    failed_response = %Response{
      status_code: 300,
      request: %Request{body: "foo", url: "https://example.com"}
    }

    success_response = %Response{status_code: 200, body: "foo"}

    {:ok,
     error: error,
     error_struct: %Subject{payload: %{data: error, prefix: Segment.Analytics}},
     failed_struct: %Subject{payload: %{data: failed_response, prefix: Segment.Analytics}},
     success_response: success_response,
     success_struct: %Subject{payload: %{data: success_response, prefix: Segment.Analytics}}}
  end

  describe "build/2" do
    test "returns response formatter struct with response and prefix", %{
      success_response: response,
      success_struct: expected_response
    } do
      assert Subject.build({:ok, response}, prefix: Segment.Analytics) == expected_response
    end

    test "when error is given, returns response formatter struct with error and prefix", %{
      error: error,
      error_struct: expected_response
    } do
      assert Subject.build({:error, error}, prefix: Segment.Analytics) == expected_response
    end
  end

  describe "format/1" do
    test "when payload have a success response, resturns formatted log message",
         %{success_struct: %Subject{payload: payload}} do
      assert Subject.format(payload) == ~s([Segment.Analytics] call success: 200 with body: foo)
    end

    test "when payload have a failed response, returns formatted log message",
         %{failed_struct: %Subject{payload: payload}} do
      assert Subject.format(payload) ==
               ~s([Segment.Analytics] call failed: %HTTPoison.Response{) <>
                 ~s(body: nil, headers: [], request: %HTTPoison.Request{body: ) <>
                 ~s("foo", headers: [], method: :get, options: [], params: %{}, ) <>
                 ~s(url: \"https://example.com\"}, request_url: nil, status_code:) <>
                 ~s( 300} with request body: foo)
    end

    test "when payload have an error, returns formatted log message", %{
      error_struct: %Subject{payload: payload}
    } do
      assert Subject.format(payload) ==
               ~s([Segment.Analytics] call failed: %HTTPoison.Error{id: nil, ) <>
                 ~s(reason: "foo"} with reason: "foo")
    end
  end
end
