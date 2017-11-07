defmodule AnalyticsElixir.Mixfile do
  use Mix.Project

  def project do
    [
      app: :segment,
      version: "1.0.0",
      elixir: "~> 1.5",
      deps: deps(),
      description: "analytics_elixir",
      package: package(),
      preferred_cli_env: [
        vcr: :test, "vcr.delete": :test, "vcr.check": :test, "vcr.show": :test
      ],
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [
      mod: {Segment.Application, []},
      extra_applications: [:logger],
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 0.13"},
      {:poison, "~> 3.1"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:exvcr, "~> 0.9", only: :test},
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Luke Swithenbank"],
      licenses: ["MIT"],
      links: %{ "GitHub" => "https://github.com/lswith/analytics-elixir" }
    ]
  end
end
