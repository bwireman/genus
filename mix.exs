defmodule Genus.MixProject do
  use Mix.Project

  def project do
    [
      app: :genus,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: [
        files: ["README.md", "mix*", "lib/genus/*.ex", "lib/genus.ex"]
      ]
    ]
  end

  def application do
    []
  end

  defp deps do
    []
  end
end
