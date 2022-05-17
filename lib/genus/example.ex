defmodule Genus.Example do
  use Genus

  defmodule E do
    genus(
      name: "E",
      fields: [
        [:a, :string],
        [:b, :bool],
        [:c, :integer],
        [:d, :external, "F"]
      ]
    )
  end

  defmodule F do
    genus(
      name: "F",
      fields: [
        [:a, :string],
        [:b, :bool],
        {[:c, :integer], 1}
      ]
    )
  end

  genus(
    name: "Example",
    imports: [F: "F"],
    fields: [
      {[:a, :string], "Hello"},
      {[:b, :bool], false},
      {[:c, :list, :bool], []},
      {[:d, :list, "E"], []},
      [:e, :external, "E"],
      [:f, :external, "F"],
      {[:g, :union, "Colors", true, [:blue, :green, :red]], :blue},
      [:h, :union, "EF", false, ["E", "F"]],
      {[:i, :union, "Numbers", [1, 2, 3, 4, 5]], 1},
      {[:j, "Colors"], :required},
      [:k],
      {[:l, :float], :required}
    ]
  )
end
