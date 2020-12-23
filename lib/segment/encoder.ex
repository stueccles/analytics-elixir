defmodule Segment.Encoder do
  @moduledoc """
  Responsible to transforming structs into JSON strings.
  """

  @doc """
  Encodes a given struct into a JSON string.

  ## Options

      * `drop_nil_fields`: If set to `true` all the struct `nil` fields will be
      filtered out from the JSON string. Defaults to `false`.

  ## Examples

      iex> library = %Segment.Analytics.Context.Library{
      ...>   name: "foo",
      ...>   version: "1.0.0"
      ...> }
      ...> #{inspect(__MODULE__)}.encode!(library, [])
      ~s({"version":"1.0.0","transport":null,"name":"foo"})

      iex> library = %Segment.Analytics.Context.Library{
      ...>   name: "foo",
      ...>   version: "1.0.0"
      ...> }
      ...> #{inspect(__MODULE__)}.encode!(library, drop_nil_fields: true)
      ~s({"version":"1.0.0","name":"foo"})

  """
  @spec encode!(struct(), list()) :: String.t()
  def encode!(struct, options) do
    struct
    |> maybe_drop_nil_fields(options)
    |> Poison.encode!()
  end

  @spec maybe_drop_nil_fields(struct(), list()) :: String.t()
  defp maybe_drop_nil_fields(struct, options) do
    if Keyword.get(options, :drop_nil_fields) == true do
      drop_nil_fields_from_struct(struct)
    else
      struct
    end
  end

  @spec drop_nil_fields_from_struct(struct()) :: map()
  defp drop_nil_fields_from_struct(struct) do
    struct
    |> Map.from_struct()
    |> drop_nil_fields_from_map()
  end

  @spec drop_nil_fields_from_map(map()) :: map()
  def drop_nil_fields_from_map(map), do: Enum.reduce(map, %{}, &drop_nil_fields/2)

  @spec drop_nil_fields({any(), any()}, map()) :: map()
  defp drop_nil_fields({key, value}, map) when is_struct(value),
    do: Map.put(map, key, drop_nil_fields_from_struct(value))

  defp drop_nil_fields({key, value}, map) when is_map(value),
    do: Map.put(map, key, drop_nil_fields_from_map(value))

  defp drop_nil_fields({key, [item | _items] = value}, map)
       when is_list(value) and is_struct(item),
       do: Map.put(map, key, Enum.map(value, &drop_nil_fields_from_struct/1))

  defp drop_nil_fields({key, [item | _items] = value}, map)
       when is_list(value) and is_map(item),
       do: Map.put(map, key, Enum.map(value, &drop_nil_fields_from_map/1))

  defp drop_nil_fields({_field, value}, map) when is_nil(value), do: map
  defp drop_nil_fields({key, value}, map), do: Map.put(map, key, value)
end
