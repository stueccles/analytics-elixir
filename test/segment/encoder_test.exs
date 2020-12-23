defmodule Segment.EncoderTest do
  use ExUnit.Case, async: true

  alias Segment.Encoder, as: Subject

  doctest Subject

  alias Segment.Support.Factory

  describe "encode!/2" do
    setup do
      batch = Factory.build(:batch)

      {:ok, batch: batch}
    end

    test "transforms a struct into a JSON string", %{batch: batch} do
      expected_response =
        :batch
        |> Factory.map_for()
        |> Poison.encode!()

      assert Subject.encode!(batch, []) == expected_response
    end

    test "when `drop_nil_fields` options is `true`, " <>
           "returns a JSON string without `null` attributes",
         %{batch: batch} do
      expected_response =
        :batch_without_null
        |> Factory.map_for()
        |> Poison.encode!()

      assert Subject.encode!(batch, drop_nil_fields: true) == expected_response
    end

    test "when `drop_nil_fields` option is set to something different than `true`," <>
           "returns a JSON string with `null` attributes",
         %{batch: batch} do
      expected_response =
        :batch
        |> Factory.map_for()
        |> Poison.encode!()

      assert Subject.encode!(batch, drop_nil_fields: "Please don't") == expected_response
    end
  end
end
