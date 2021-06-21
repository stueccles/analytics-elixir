defmodule Segment.Analytics.ResponseFormatter do
  @moduledoc """
  Wrapper around HTTPoisong response which defines `MetaLogger.Formatter` protocol.
  """

  use TypedStruct

  alias HTTPoison.{Error, Request, Response}
  alias MetaLogger.Formatter

  @replacement "[FILTERED]"

  @filter_patterns [
    {~s("email":\s?".*"), ~s("email":"#{@replacement}")},
    {~s/"address":\s?{.*?}/, ~s/"address":{}/},
    {~s("first_name":\s?".*"), ~s("first_name":"#{@replacement}")},
    {~s("last_name":\s?".*"), ~s("last_name":"#{@replacement}")},
    {~s("phone_number":\s?".*"), ~s("phone_number":"#{@replacement}")}
  ]

  @derive {Formatter, filter_patterns: @filter_patterns, formatter_fn: &__MODULE__.format/1}

  @typedoc "Response formatter struct."
  typedstruct do
    field :payload, payload(), enforce: true
  end

  @typep payload :: %{data: Response.t() | Error.t(), prefix: any()}
  @typep http_response :: {:ok, Response.t()} | {:error, Error.t()}

  @doc """
  Builds `#{inspect(__MODULE__)} struct.`

  ## Examples

      iex> response = %#{inspect(Response)}{body: "foo", status_code: 200}
      ...> #{inspect(__MODULE__)}.build({:ok, response}, prefix: Segment.Analytics)
      %#{inspect(__MODULE__)}{
        payload: %{
          data: %#{inspect(Response)}{
            body: "foo",
            status_code: 200
          },
          prefix: Segment.Analytics
        }
      }

      iex> error = %#{inspect(Error)}{id: nil, reason: :errconect}
      ...> #{inspect(__MODULE__)}.build({:error, error}, prefix: Segment.Analytics)
      %#{inspect(__MODULE__)}{
        payload: %{
          data: %#{inspect(Error)}{id: nil, reason: :errconect},
          prefix: Segment.Analytics
        }
      }

  """
  @spec build(http_response(), Keyword.t()) :: t()
  def build(http_response, options \\ [])

  def build({status, %struct{} = response}, options)
      when status in [:ok, :error] and struct in [Error, Response],
      do: %__MODULE__{payload: %{data: response, prefix: Keyword.get(options, :prefix)}}

  @doc """
  Builds a log message from #{inspect(__MODULE__)} struct.

  ## Examples

      iex> payload = %{
      ...>   data: %#{inspect(Response)}{status_code: 200, body: "foo"},
      ...>   prefix: Segment.Analytics
      ...> }
      ...> #{inspect(__MODULE__)}.format(payload)
      ~s([Segment.Analytics] call success: 200 with body: foo)

      iex> payload = %{
      ...>   data: %#{inspect(Response)}{
      ...>     request: %#{inspect(Request)}{body: "foo", url: "https://example.com"},
      ...>     status_code: 300
      ...>   },
      ...>   prefix: Segment.Analytics
      ...> }
      ...> #{inspect(__MODULE__)}.format(payload)
      ~s([Segment.Analytics] call failed: %HTTPoison.Response{body: nil, headers: [], ) <>
        ~s(request: %HTTPoison.Request{body: "foo", headers: [], method: :get, ) <>
        ~s(options: [], params: %{}, url: "https://example.com"}, request_url: nil, ) <>
        ~s(status_code: 300} with request body: foo)

      iex> payload = %{
      ...>   data: %#{inspect(Error)}{reason: "foo"},
      ...>   prefix: Segment.Analytics,
      ...> }
      ...> #{inspect(__MODULE__)}.format(payload)
      ~s([Segment.Analytics] call failed: %HTTPoison.Error{id: nil, reason: "foo"}) <>
        ~s( with reason: "foo")

  """
  @spec format(payload()) :: String.t()
  def format(%{data: %Response{status_code: status_code, body: body}, prefix: prefix})
      when status_code in 200..299 do
    [
      "[",
      inspect(prefix),
      "] call success: ",
      status_code,
      " with body: ",
      body
    ]
    |> Enum.join()
  end

  def format(%{data: %Response{request: %Request{body: body}} = response, prefix: prefix}) do
    [
      "[",
      inspect(prefix),
      "] call failed: ",
      inspect(response),
      " with request body: ",
      body
    ]
    |> Enum.join()
  end

  def format(%{data: %Error{reason: reason} = error, prefix: prefix}) do
    [
      "[",
      inspect(prefix),
      "] call failed: ",
      inspect(error),
      " with reason: ",
      inspect(reason)
    ]
    |> Enum.join()
  end
end
