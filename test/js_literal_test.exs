defmodule JSLiteralTest do
  use ExUnit.Case

  test "String" do
    assert "\"Foo\"" = Genus.JSLiteral.literal("Foo")
    assert "\"\"" = Genus.JSLiteral.literal("")
  end

  test "Integer" do
    assert "-1" = Genus.JSLiteral.literal(-1)
    assert "0" = Genus.JSLiteral.literal(0)
    assert "1" = Genus.JSLiteral.literal(1)
  end

  test "Float" do
    assert "-1.1" = Genus.JSLiteral.literal(-1.1)
    assert "0.1" = Genus.JSLiteral.literal(0.1)
    assert "1.1" = Genus.JSLiteral.literal(1.1)
  end

  test "Atom" do
    assert "undefined" = Genus.JSLiteral.literal(nil)
    assert "true" = Genus.JSLiteral.literal(true)
    assert "false" = Genus.JSLiteral.literal(false)
    assert "\"foo\"" = Genus.JSLiteral.literal(:foo)
  end

  test "Map" do
    assert "{}" = Genus.JSLiteral.literal(%{}) |> String.replace("\n", "")

    assert "{\"list\":[1],\"num\":1,\"text\":\"text\"}" =
             Genus.JSLiteral.literal(%{text: "text", num: 1, list: [1]})
             |> String.replace("\n", "")
  end

  test "List" do
    test = [nil, true, false, :bar, -1, 0, 1, -1.1, 0.1, 1.1, "", [], %{}]

    result = "[undefined, true, false, \"bar\", -1, 0, 1, -1.1, 0.1, 1.1, \"\", [], {}]"

    assert result == Genus.JSLiteral.literal(test) |> String.replace("\n", "")
  end
end
