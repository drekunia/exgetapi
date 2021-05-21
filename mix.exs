defmodule Exgetapi.MixProject do
  use Mix.Project

  def project do
    [
      app: :exgetapi,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :cowboy, :plug, :poison],
      mod: {Exgetapi.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:ecto_sql, "~> 3.6.1"},
      {:postgrex, "~> 0.15.9"},
      {:cowboy, "~> 2.9"},
      {:plug, "~> 1.11"},
      {:poison, "~> 4.0"},
      {:plug_cowboy, "~> 2.5"},
      {:jason, "~> 1.2"}
    ]
  end
end
