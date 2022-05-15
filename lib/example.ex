defmodule Example do
  use Genus

  defmodule E do
    genus(
      name: "E",
      fields: [
        [:a, :string],
        [:b, :bool],
        [:c, :integer],
        [:e, :external, "F"]
      ]
    )
  end

  defmodule F do
    genus(
      name: "F",
      fields: [
        [:a, :string],
        [:b, :bool],
        [:c, :integer]
      ]
    )
  end

  genus(
    name: "Example",
    fields: [
      {[:a, :string], "Hello"},
      {[:b, :bool], false},
      {[:l, :list, :bool], []},
      {[:c, :list, "E"], []},
      [:d, :external, "E"],
      [:e, :external, "F"],
      {[:colors, :union, "Colors", true, [:blue, :green, :red]], :blue},
      [:ef, :union, "EF", false, ["E", "F"]],
      {[:numbers, :union, "Numbers", [1, 2, 3, 4, 5]], 1},
      [:more_colors, "Colors"],
      [:a_val]
    ]
  )
end
