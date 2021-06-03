defmodule Segment.Analytics.ResponseFormatter do
  @moduledoc """
  Wrapper around HTTPoisong response which defines MetaLogger.Formatter protocol
  """
  alias HTTPoison.{Error, Response}
  @replacement "[FILTERED]"

  @filter_patterns [
    {~s("email":\s?".*"), ~s("email":"#{@replacement}")},
    {~s/"address":\s?{.*?}/, ~s/"address":{}/},
    {~s("first_name":\s?".*"), ~s("first_name":"#{@replacement}")},
    {~s("last_name":\s?".*"), ~s("last_name":"#{@replacement}")},
    {~s("phone_number":\s?".*"), ~s("phone_number":"#{@replacement}")}
  ]
  @derive {
    MetaLogger.Formatter,
    filter_patterns: @filter_patterns, formatter_fn: &__MODULE__.format/1
  }
  defstruct [:payload, :status]

  @type t() :: %__MODULE__{payload: any(), status: atom()}
  @type http_response :: {:ok, Response.t()} | {:error, Error.t()}

  @spec build(http_response()) :: t()
  def build({status, result}) do
    struct(__MODULE__, payload: result, status: status)
  end

  def format(%Response{status_code: code} = response) when code in 200..299 do
    "[Segment.Analytics] call success: #{code} with body: #{response.body}"
  end

  def format(%Response{request: request} = response) do
    "[Segment.Analytics] call failed: #{inspect(response)} with request body: #{inspect(request.body)}"
  end

  def format(%Error{reason: reason} = error) do
    "[Segment.Analytics] call failed: #{inspect(error)} with reason: #{inspect(reason)}"
  end
end
