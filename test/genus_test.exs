defmodule GenusTest do
  use ExUnit.Case
  alias Genus.Example

  test "Example" do
    ex = %Example{j: :blue, l: 2.22}
    assert ex.a == "Hello"
    assert ex.b == false
    assert ex.c == []
    assert ex.d == []
    assert ex.e == nil
    assert ex.f == nil
    assert ex.g == :blue
    assert ex.h == nil
    assert ex.i == 1
    assert ex.j == :blue
    assert ex.k == nil
    assert ex.l == 2.22
    assert ex.m == nil
  end

  test "E" do
    e = %Example.E{}
    assert e.a == nil
    assert e.b == nil
    assert e.c == nil
    assert e.d == nil
  end

  test "F" do
    f = %Example.F{}
    assert f.a == nil
    assert f.b == nil
    assert f.c == 1
  end

  test "Indentifier" do
    id = %Example.Identifier{}
    assert id.id == nil
  end
end
