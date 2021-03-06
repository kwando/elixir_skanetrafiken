defmodule Skanetrafiken.MixProject do
  use Mix.Project

  def project do
    [
      app: :skanetrafiken,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mix_test_watch, ">= 0.0.0", runtime: false, only: :dev},
      {:sweet_xml, "~> 0.6"},
      {:httpoison, "~> 1.6"}
    ]
  end
end
