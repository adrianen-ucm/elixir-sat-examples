defmodule Sat.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_sat_examples,
      version: "1.0.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:porcelain, :exile],
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:porcelain, "~> 2.0"},
      {:ex_doc, "~> 0.28.2", only: :dev},
      {:exile, git: "https://github.com/akash-akya/exile"}
    ]
  end
end
