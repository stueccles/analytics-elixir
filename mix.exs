defmodule AnalyticsElixir.Mixfile do
  use Mix.Project

  def project do
    [
      app: :segment,
      version: "0.2.3",
      elixir: "~> 1.0",
      deps: deps(),
      description: "analytics_elixir",
      dialyzer: [plt_add_deps: [:app_tree]],
      package: package()
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:hackney, :logger, :retry, :tesla, :jason, :telemetry]]
  end

  # Dependencies can be Hex package
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:dialyxir, "~> 1.0.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:hackney, "~> 1.15"},
      {:jason, ">= 1.0.0"},
      {:mox, "~> 0.5", only: :test},
      {:retry, "~> 0.13"},
      {:telemetry, "~> 0.4.2"},
      {:tesla, "~> 1.2"}
    ]
  end

  defp package do
    # These are the default files included in the package
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Stuart Eccles"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/stueccles/analytics-elixir"}
    ]
  end
end
