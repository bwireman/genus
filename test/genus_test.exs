defmodule GenusTest do
  use ExUnit.Case

  test "Example" do
    ex = %Example{}
    assert ex.a == "Hello"
    assert ex.b == false
    assert ex.c == []
    assert ex.d == []
    assert ex.e == nil
    assert ex.f == nil
    assert ex.g == :blue
    assert ex.h == nil
    assert ex.i == 1
    assert ex.j == nil
    assert ex.k == nil
    assert ex.l == 3.14
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
    assert f.c == nil
  end
end
