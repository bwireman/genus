defmodule Genus.Example do
  use Genus

  defmodule E do
    tschema name: "E" do
      field(:a, :string)
      field(:b, :bool)
      field(:c, :integer)
      field(:d, :external, "F")
      field(:fizz, :union, "FizzBuzz", true, [:fizz, :buzz, :fizz_buzz], default: :fizz)
    end
  end

  defmodule F do
    tschema name: "F" do
      field(:a, :string)
      field(:b, :bool)
      field(:c, :integer, default: 1)
    end
  end

  defmodule Identifier do
    tschema do
      field(:id, :integer)
    end
  end

  tschema name: "Example", imports: [F: "F", FizzBuzz: "E"] do
    field(:a, :string, default: "Hello")
    field(:b, :bool, default: false)
    field(:c, :list, :bool, default: [])
    field(:d, :list, "E", default: [])
    field(:e, :external, "E")
    field(:f, :external, "F")
    field(:g, :union, "Colors", true, [:blue, :green, :red], default: :blue)
    field(:h, :union, "EF", false, ["E", "F"])
    field(:i, :union, "Numbers", [1, 2, 3, 4, 5], default: 1)
    field(:j, "Colors", required: true)
    field(:k)
    field(:l, :float, required: true)
    field(:m, "FizzBuzz")
  end
end
