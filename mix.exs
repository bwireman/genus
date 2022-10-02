defmodule Genus.MixProject do
  use Mix.Project

  def project do
    [
      app: :genus,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :eex]
    ]
  end

  defp deps do
    [
      {:ecto_sql, "~> 3.9"},
      {:phoenix, "~> 1.6"}
    ]
  end
end
